require "#{Rails.root}/app/helpers/devices_helper"
include DevicesHelper

namespace :smart_thermostat do

  desc 'Update training dataset'
  task(:training_dataset => [:environment]) do |t, args|
    smart_thermostat_devices = Device.select(:uid).where(type_c_id: Device::TYPES[:SMART_THERMOSTAT][:ID])
    smart_thermostat_devices.each do |smart_thermostat_device|

      # current_day_start = Time.now.at_beginning_of_day
      current_day_start = Time.new(2017, 9, 21, 16, 35, 32).at_beginning_of_day
      current_day_end   = current_day_start.at_end_of_day

      puts current_day_start
      puts current_day_end

      query_string = 'device_uid = :device_uid'
      query_string += ' AND '
      query_string += 'energy_source_status = :energy_source_status'
      query_string += ' AND '
      query_string += '(sample_datetime BETWEEN :current_day_start AND :current_day_end)'
      query_params = {
          device_uid:           smart_thermostat_device.uid,
          energy_source_status: 1,
          current_day_start:    current_day_start.to_formatted_s(:db),
          current_day_end:      current_day_end.to_formatted_s(:db)
      }

      distinct_outside_temperatures = SmartThermostatHistorySample.select(:outside_temperature).where([query_string, query_params]).distinct.pluck(:outside_temperature).sort

      query_string += ' AND '
      query_string += 'outside_temperature = :distinct_outside_temperature'

      query_params[:distinct_outside_temperature] = nil

      distinct_outside_temperatures.each do |distinct_outside_temp|
        query_params[:distinct_outside_temperature] = distinct_outside_temp
        samples                                     = SmartThermostatHistorySample.where([query_string, query_params])

        previous_sample_to_compare_with = samples.first
        samples.find_each do |sample|
          puts 'Current sample'
          pp sample
          temp_diff = (sample.inside_temperature - previous_sample_to_compare_with.inside_temperature).round(1)

          if temp_diff >= 0.1
            puts 'Anodos temp entopistike'

            puts temp_diff

            time_diff = (sample.sample_datetime.to_formatted_s(:db).to_time - previous_sample_to_compare_with.sample_datetime.to_formatted_s(:db).to_time).to_i
            puts time_diff

            # CHECK START TIME
            puts "CHECK #{smart_thermostat_device.uid} #{distinct_outside_temp} #{previous_sample_to_compare_with.inside_temperature}"
            start_training_temp = SmartThermostatTraining.where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp, inside_temperature: previous_sample_to_compare_with.inside_temperature)
            if start_training_temp.any?
              puts 'Start training temp exists'
              start_training_set = start_training_temp.take
              pp start_training_set
            else
              puts 'start Training temp not exists'
              smaller_training_sets = SmartThermostatTraining
                                          .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                          .where(['inside_temperature < :temp_to_search', { temp_to_search: previous_sample_to_compare_with.inside_temperature }])
                                          .order(:inside_temperature)

              start_training_set                     = SmartThermostatTraining.new
              start_training_set.device_uid          = smart_thermostat_device.uid
              start_training_set.outside_temperature = distinct_outside_temp
              start_training_set.inside_temperature  = previous_sample_to_compare_with.inside_temperature
              if smaller_training_sets.empty?
                puts 'No smaller temps'
                puts "INPUT TO DATABASE: OUTS=#{distinct_outside_temp}, INS=#{previous_sample_to_compare_with.inside_temperature}, TIME=#{0}"

                start_training_set.timeline = 0
              else
                puts 'Smaller temps exists'
                next_training_sets = SmartThermostatTraining
                                         .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                         .where(['inside_temperature > :temp_to_search', { temp_to_search: previous_sample_to_compare_with.inside_temperature }])
                                         .order(:inside_temperature)

                previous_training_set = smaller_training_sets.last
                next_training_set     = next_training_sets.first

                puts 'previous'
                pp previous_training_set
                puts 'next'
                pp next_training_set

                previous_next_temp_diff = (next_training_set.inside_temperature - previous_training_set.inside_temperature) * 10.to_i
                puts previous_next_temp_diff

                current_previous_temp_diff = (previous_sample_to_compare_with.inside_temperature - previous_training_set.inside_temperature) * 10.to_i
                puts current_previous_temp_diff

                estimated_timeline_for_training_set = (((next_training_set.timeline - previous_training_set.timeline) / previous_next_temp_diff) * current_previous_temp_diff).to_i
                puts estimated_timeline_for_training_set

                start_training_set.timeline = estimated_timeline_for_training_set
              end
              start_training_set.save
            end

            #  CHECK END TIME
            end_training_set = SmartThermostatTraining.where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp, inside_temperature: sample.inside_temperature)
            if end_training_set.empty?
              puts 'End training temp not exists'
              bigger_training_temps = SmartThermostatTraining
                                          .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                          .where(['inside_temperature > :temp_to_search', { temp_to_search: sample.inside_temperature }])
                                          .order(:inside_temperature)

              end_training_set                     = SmartThermostatTraining.new
              end_training_set.device_uid          = smart_thermostat_device.uid
              end_training_set.outside_temperature = distinct_outside_temp
              end_training_set.inside_temperature  = sample.inside_temperature
              if bigger_training_temps.any?
                first_bigger = bigger_training_temps.first
                if (start_training_set.timeline + time_diff) <= first_bigger.timeline
                  end_training_set.timeline = start_training_set.timeline + time_diff
                else
                  end_training_set.timeline = start_training_set.timeline + time_diff
                  # Must add the absolute difference to the rest sets
                  abs_diff = (end_training_set.timeline - first_bigger.timeline).abs
                  bigger_training_temps.each do |bigger_training_set|
                    bigger_training_set.timeline += abs_diff
                    bigger_training_set.save
                  end
                end
              else
                end_training_set.timeline = start_training_set.timeline + time_diff
              end

              end_training_set.save
            else
              puts 'End training set exists'
              end_training_set = end_training_set.take
              # So chedk if timeline time is different
              if (start_training_set.timeline + time_diff) != end_training_set.timeline
                # Must update the next values accordingly
                diff_to_add                    = (start_training_set.timeline + time_diff) - end_training_set.timeline
                current_and_next_training_sets = SmartThermostatTraining
                                                     .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                                     .where(['inside_temperature >= :temp_to_search', { temp_to_search: sample.inside_temperature }])
                                                     .order(:inside_temperature)

                current_and_next_training_sets.each do |training_set|
                  training_set.timeline += diff_to_add
                  training_set.save
                end

                # Must do something with the values between start and stop, if exists, end timeline values are smaller than end's
                between_start_and_stop_training_sets = SmartThermostatTraining
                                                           .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                                           .where(
                                                               [
                                                                   '(inside_temperature BETWEEN :start_training_set_inside_temp AND :end_training_set_inside_temp) AND timeline < :end_training_set_timeline',
                                                                   {
                                                                       start_training_set_timeline: start_training_set.inside_temperature,
                                                                       end_training_set_timeline:   end_training_set.inside_temperature,
                                                                       end_training_set_timeline:   end_training_set.timeline
                                                                   }
                                                               ]
                                                           )
                                                           .order(:inside_temperature)


                puts between_start_and_stop_training_sets.to_sql

                pp between_start_and_stop_training_sets

              end
            end

            previous_sample_to_compare_with = sample


          elsif temp_diff < 0
            puts 'Kathodos temp entopistike'
            previous_sample_to_compare_with = sample
          end

          puts

        end

      end

    end
  end

  desc 'Take sample from device attributes for smart thermostat history and training'
  task(:history_sample => [:environment]) do |t, args|
    smart_thermostat_devices = Device.select(:uid, :last_contact_at).where(type_c_id: Device::TYPES[:SMART_THERMOSTAT][:ID])
    if smart_thermostat_devices.any?

      smart_thermostat_devices.each do |smart_thermostat_device|
        if !device_online?(smart_thermostat_device.last_contact_at)
          next
        end

        smart_thermostat_attributes_associations = SmartThermostat.where(smart_device_uid: smart_thermostat_device.uid)
        if smart_thermostat_attributes_associations.any?
          # Find working status
          device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:WORKING_STATUS][:ID]).source_device_attribute_id
          working_state       = DeviceAttribute.find(device_attribute_id).current_value.to_i
          # Find outside temperature
          device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:OUTSIDE_TEMPERATURE][:ID]).source_device_attribute_id
          outside_temperature = DeviceAttribute.find(device_attribute_id).current_value.round(0)
          # Find inside temperature
          device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:INSIDE_TEMPERATURE][:ID]).source_device_attribute_id
          inside_temperature  = DeviceAttribute.find(device_attribute_id).current_value.round(1)
          # Find set temperature
          device_attribute_id = smart_thermostat_attributes_associations.find_by(smart_device_attribute_type_c_id: SmartThermostat::SMART_DEVICE_ATTRIBUTE_TYPES[:SET_TEMPERATURE][:ID]).source_device_attribute_id
          set_temperature     = DeviceAttribute.find(device_attribute_id).set_value.round(1)
          # Time now
          sample_datetime = Time.now.change(sec: 0)

          # Prepare the sample
          sample                      = SmartThermostatHistorySample.new
          sample.device_uid           = smart_thermostat_device.uid
          sample.sample_datetime      = sample_datetime.to_formatted_s(:db)
          sample.energy_source_status = working_state
          sample.outside_temperature  = outside_temperature
          sample.inside_temperature   = inside_temperature
          sample.set_temperature      = set_temperature
          sample.save
        else
          puts 'Smart thermostat associations missing'
        end
      end

    else
      puts 'No Smart Thermostat'
    end
  end

  desc 'Check which devices are offline for a certain amount of time and send notification to user owner'
  task(:send_notification_for_offline_devices => [:environment]) do |t, args|
    offline_period       = Rails.application.secrets.configs[:send_email_notification_after_device_offine_period_in_minutes]
    current_time         = Time.now
    minimum_offline_time = current_time.ago(offline_period.minutes).to_formatted_s(:db)

    offline_devices_to_send_notification_for = Device.where(
        [
            'long_offline_time_notification = :long_offline_time_notification AND last_contact_at <= :minimum_offline_time',
            {
                minimum_offline_time:           minimum_offline_time,
                long_offline_time_notification: Device::OFFLINE_NOTIFICATION_STATUS[:NOT_SEND]
            }
        ]
    )

    offline_devices_to_send_notification_for.find_each do |offline_device|
      UserMailer.notify_user_for_offline_devices(offline_device).deliver_now
      offline_device.long_offline_time_notification = Device::OFFLINE_NOTIFICATION_STATUS[:EMAIL_SEND]
      offline_device.save
    end
  end

end

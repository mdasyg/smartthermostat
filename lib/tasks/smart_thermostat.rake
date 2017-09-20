require "#{Rails.root}/app/helpers/devices_helper"
include DevicesHelper

namespace :smart_thermostat do

  desc 'Update training dataset'
  task(:analyze_training_set => [:environment]) do |t, args|
    smart_thermostat_devices = Device.select(:uid).where(type_c_id: Device::TYPES[:SMART_THERMOSTAT][:ID])
    smart_thermostat_devices.each do |smart_thermostat_device|

      current_day_start = Time.now.at_beginning_of_day
      # current_day_start = Time.new(2017, 9, 21, 16, 35, 32).at_beginning_of_day
      current_day_end = current_day_start.at_end_of_day

      puts current_day_start
      puts current_day_end

      # Base query string and params
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

      # Query for disting outside temp values
      distinct_outside_temperatures = SmartThermostatTrainingSetSample.select(:outside_temperature).where([query_string, query_params]).distinct.pluck(:outside_temperature).sort

      # Additional query params in order to select each distinct outside temperature
      query_string                                += ' AND '
      query_string                                += 'outside_temperature = :distinct_outside_temperature'
      query_params[:distinct_outside_temperature] = nil

      distinct_outside_temperatures.each do |distinct_outside_temp|
        query_params[:distinct_outside_temperature]    = distinct_outside_temp
        training_set_for_current_distinct_outside_temp = SmartThermostatTrainingSetSample.where([query_string, query_params])

        previous_training_set_sample_to_compare_with = training_set_for_current_distinct_outside_temp.first
        training_set_for_current_distinct_outside_temp.find_each do |training_set_sample_to_analyze|
          puts 'Current training_set_sample_to_analyze'
          pp training_set_sample_to_analyze
          temp_diff = (training_set_sample_to_analyze.inside_temperature - previous_training_set_sample_to_compare_with.inside_temperature).round(1)

          if temp_diff >= 0.1
            puts 'Anodos temp entopistike'

            puts temp_diff

            time_diff = (training_set_sample_to_analyze.sample_datetime.to_formatted_s(:db).to_time - previous_training_set_sample_to_compare_with.sample_datetime.to_formatted_s(:db).to_time).to_i
            puts time_diff

            # CHECK START TIME
            start_dataset = SmartThermostatComputedDataset.where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp, inside_temperature: previous_training_set_sample_to_compare_with.inside_temperature)
            if start_dataset.any?
              puts 'Start dataset'
              start_dataset = start_dataset.take
              pp start_dataset
            else
              puts 'Start dataset not exists'
              previous_datasets = SmartThermostatComputedDataset
                                      .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                      .where(['inside_temperature < :temp_to_search', { temp_to_search: previous_training_set_sample_to_compare_with.inside_temperature }])
                                      .order(:inside_temperature)

              start_dataset                     = SmartThermostatComputedDataset.new
              start_dataset.device_uid          = smart_thermostat_device.uid
              start_dataset.outside_temperature = distinct_outside_temp
              start_dataset.inside_temperature  = previous_training_set_sample_to_compare_with.inside_temperature
              if previous_datasets.empty?
                puts 'No previous datasets'
                puts "INPUT TO DATABASE: OUTS=#{distinct_outside_temp}, INS=#{previous_training_set_sample_to_compare_with.inside_temperature}, TIME=#{0}"
                start_dataset.timeline = 0
              else
                puts 'Previous datasets exists'
                next_datasets = SmartThermostatComputedDataset
                                    .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                    .where(['inside_temperature > :temp_to_search', { temp_to_search: previous_training_set_sample_to_compare_with.inside_temperature }])
                                    .order(:inside_temperature)

                previous_training_set = previous_datasets.last
                next_training_set     = next_datasets.first

                puts 'previous'
                pp previous_training_set
                puts 'next'
                pp next_training_set

                previous_next_temp_diff = (next_training_set.inside_temperature - previous_training_set.inside_temperature) * 10.to_i
                puts previous_next_temp_diff

                current_previous_temp_diff = (previous_training_set_sample_to_compare_with.inside_temperature - previous_training_set.inside_temperature) * 10.to_i
                puts current_previous_temp_diff

                estimate_timeline__value_to_add_in_start_dataset = (((next_training_set.timeline - previous_training_set.timeline) / previous_next_temp_diff) * current_previous_temp_diff).to_i
                puts estimate_timeline__value_to_add_in_start_dataset

                start_dataset.timeline = previous_training_set.timeline + estimate_timeline__value_to_add_in_start_dataset
              end
              start_dataset.save
            end

            #  CHECK END dataset
            end_dataset = SmartThermostatComputedDataset.where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp, inside_temperature: training_set_sample_to_analyze.inside_temperature)
            if end_dataset.empty?
              puts 'End dataset not exists'
              next_datasets = SmartThermostatComputedDataset
                                  .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                  .where(['inside_temperature > :temp_to_search', { temp_to_search: training_set_sample_to_analyze.inside_temperature }])
                                  .order(:inside_temperature)

              end_dataset                     = SmartThermostatComputedDataset.new
              end_dataset.device_uid          = smart_thermostat_device.uid
              end_dataset.outside_temperature = distinct_outside_temp
              end_dataset.inside_temperature  = training_set_sample_to_analyze.inside_temperature
              if next_datasets.any?
                first_from_next_datasets = next_datasets.first
                if (start_dataset.timeline + time_diff) <= first_from_next_datasets.timeline
                  end_dataset.timeline = start_dataset.timeline + time_diff
                else
                  end_dataset.timeline = start_dataset.timeline + time_diff
                  # Must add the absolute difference to the rest sets
                  abs_diff = (end_dataset.timeline - first_from_next_datasets.timeline).abs
                  next_datasets.each do |next_dataset|
                    next_dataset.timeline += abs_diff
                    next_dataset.save
                  end
                end
              else
                end_dataset.timeline = start_dataset.timeline + time_diff
              end

              end_dataset.save
            else
              puts 'End dataset exists'
              end_dataset = end_dataset.take
              # So chedk if timeline time is different
              if (start_dataset.timeline + time_diff) != end_dataset.timeline
                # Must update the next values accordingly
                diff_to_add               = (start_dataset.timeline + time_diff) - end_dataset.timeline
                current_and_next_datasets = SmartThermostatComputedDataset
                                                .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                                .where(['inside_temperature >= :temp_to_search', { temp_to_search: training_set_sample_to_analyze.inside_temperature }])
                                                .order(:inside_temperature)

                current_and_next_datasets.each do |next_dataset|
                  next_dataset.timeline += diff_to_add
                  next_dataset.save
                end

                # Must do something with the values between start and stop, if exists, end timeline values are smaller than end's
                between_start_and_stop_training_sets = SmartThermostatComputedDataset
                                                           .where(device_uid: smart_thermostat_device.uid, outside_temperature: distinct_outside_temp)
                                                           .where(
                                                               [
                                                                   '(inside_temperature BETWEEN :start_training_set_inside_temp AND :end_training_set_inside_temp) AND timeline < :end_training_set_timeline',
                                                                   {
                                                                       start_training_set_inside_temp: start_dataset.inside_temperature,
                                                                       end_training_set_inside_temp:   end_dataset.inside_temperature,
                                                                       end_training_set_timeline:      end_dataset.timeline
                                                                   }
                                                               ]
                                                           )
                                                           .order(:inside_temperature)

                puts between_start_and_stop_training_sets.to_sql

                pp between_start_and_stop_training_sets

              end
            end

            previous_training_set_sample_to_compare_with = training_set_sample_to_analyze

          elsif temp_diff < 0
            puts 'Kathodos temp entopistike'
            previous_training_set_sample_to_compare_with = training_set_sample_to_analyze
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
          sample                      = SmartThermostatTrainingSetSample.new
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

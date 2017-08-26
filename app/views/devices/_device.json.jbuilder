json.uid device.uid.to_s
json.name device.name
json.location device.location
json.description device.description
json.last_contact_text compute_device_status_indication(device.last_contact_at)

json.device_attributes device.device_attributes.each do |device_attribute|
  json.id device_attribute.id.to_s
  json.name device_attribute.name
  json.min_value device_attribute.min_value
  json.max_value device_attribute.max_value
  json.set_value device_attribute.set_value
  json.current_value_text compute_device_attribute_text(device_attribute.current_value, device_attribute.unit, device_attribute.updated_at)
end

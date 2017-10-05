json.uid device.uid.to_s
json.name device.name
json.location device.location
json.description device.description
json.device_status device_online?(device.last_contact_at)
json.last_contact_text get_device_online_status(device.last_contact_at)

json.device_attributes device.device_attributes.each do |device_attribute|
  json.id device_attribute.id.to_s
  json.name device_attribute.name
  json.min_value get_min_value_text(device_attribute.primitive_type_c_id, device_attribute.min_value)
  json.max_value get_max_value_text(device_attribute.primitive_type_c_id, device_attribute.max_value)
  json.set_value compute_device_attribute_set_or_current_value(device_attribute.primitive_type_c_id, device_attribute.set_value, false)
  json.current_value_text compute_device_attribute_set_or_current_value(device_attribute.primitive_type_c_id, device_attribute.current_value, true)
end

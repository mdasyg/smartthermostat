json.extract! device, :id, :id, :name, :location, :description, :access_token, :last_contact_at, :created_at, :updated_at
json.url device_url(device, format: :json)
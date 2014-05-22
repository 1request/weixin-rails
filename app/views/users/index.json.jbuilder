json.array!(@users) do |user|
  json.extract! user, :id, :id
  json.url user_url(user, format: :json)
end

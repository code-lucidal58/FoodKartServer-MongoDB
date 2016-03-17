# json.array!(@users) do |user|
#   json.extract! user, :id, :name, :email, :phone, :password
# end
json.success @success
json.data (@users) do |user|
  json.id user.id
  json.name  user.name
  json.email  user.email
  json.phone  user.phone
end

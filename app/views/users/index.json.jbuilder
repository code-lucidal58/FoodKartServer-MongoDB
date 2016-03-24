# json.array!(@users) do |user|
#   json.extract! user, :id, :name, :email, :phone, :password
# end
json.success @success
if @success
  json.data (@users) do |user|
    json.access_token user.access_token
    json.id user.id
    json.name user.name
    json.email user.email
    json.phone user.phone
    json.address user.address
    json.created_at user.created_at
    json.updated_at user.updated_at
  end
end

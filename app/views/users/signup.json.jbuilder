json.success @result.success
if @result.success=="true"
  json.data  do
    json.access_token @user.access_token
    json.id @user.id
    json.name @user.name
    json.email @user.email
    json.phone @user.phone
    json.address @user.address
    json.created_at @user.created_at
    json.updated_at @user.updated_at
  end
# else
#   json.error @result.error
end
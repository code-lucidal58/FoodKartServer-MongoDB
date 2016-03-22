json.success @result.success
if !@result.success
  json.error @result.error
end
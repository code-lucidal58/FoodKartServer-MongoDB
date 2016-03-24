class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email, type: String
  field :phone, type: String
  field :address, type: String
  field :password, type: String

  #private fields
  field :salt, type: String
  field :access_token, type: String
  field :active, type: Mongoid::Boolean, default: true

  #validations
  validates_uniqueness_of :email, :case_sensitive => false
  validates_uniqueness_of :phone
end

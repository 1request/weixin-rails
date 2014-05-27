class Customer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :fromUser, type: String
  field :name, type: String
end

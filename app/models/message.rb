class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :customer_id, type: String
  field :message_type, type: String
  field :message, type: String
end

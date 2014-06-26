class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :account_id, type: String
  field :customer_id, type: String
  field :message_type, type: String
  field :message, type: String
  field :content_type, type: String
  field :weixin_msg_id, type: String

  mount_uploader :media, MediaUploader
end

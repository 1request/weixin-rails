class Account
  include Mongoid::Document
  include Mongoid::Timestamps
  include WeixinRailsMiddleware::AutoGenerateWeixinTokenSecretKey

  field :id, type: String
  field :name, type: String
  field :app_id, type: String
  field :app_secret, type: String
  field :weixin_id, type: String
  field :weixin_secret_key, type: String
  field :weixin_token, type: String
end
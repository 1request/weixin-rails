class KfController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  after_filter :set_access_control_headers
  before_action :set_client

  def index
    @client.followers.result['data']['openid'].each do |follower|
      customer = Customer.where(:fromUser => follower).first
      unless customer
        id = BSON::ObjectId.new
        customer = Customer.create(_id: id.to_s, fromUser: follower)
      end

      customer.user_info = @client.user(follower).result
      customer.save
    end

    head :created
  end

  def create
    @client.send_text_custom(params[:weixin_id], params[:q])

    head :created
  end

private
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = 'http://kf.xin.io'
    headers['Access-Control-Request-Method'] = '*'
  end

  def set_client
    @client ||= WeixinAuthorize::Client.new("wxe2e163d3337f28ee", "0ce603e4068fd1f8ee5ef324473d5687")
  end
end

class KfController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  after_filter :set_access_control_headers

  def index
    client ||= WeixinAuthorize::Client.new("wxe2e163d3337f28ee", "0ce603e4068fd1f8ee5ef324473d5687")
    client.followers.result['data']['openid'].each do |follower|
      customer = Customer.where(:fromUser => follower).first
      customer = Customer.create(:fromUser => follower) unless customer

      client ||= WeixinAuthorize::Client.new("wxe2e163d3337f28ee", "0ce603e4068fd1f8ee5ef324473d5687")
      customer.user_info = client.user(follower).result
      customer.save
    end

    head :created
  end

  def create
    client ||= WeixinAuthorize::Client.new("wxe2e163d3337f28ee", "0ce603e4068fd1f8ee5ef324473d5687")
    client.send_text_custom(params[:weixin_id], params[:q])

    head :created
  end

  def set_access_control_headers 
    headers['Access-Control-Allow-Origin'] = 'http://localhost:4000' 
    headers['Access-Control-Request-Method'] = '*' 
  end


end

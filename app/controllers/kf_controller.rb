class KfController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  after_filter :set_access_control_headers

  def index
    client.followers.result['data']['openid'].each do |follower|
      customer = Customer.where(:fromUser => follower).first
      unless customer
        id = BSON::ObjectId.new
        customer = Customer.create(_id: id.to_s, fromUser: follower)
      end

      customer.user_info = client.user(follower).result
      customer.save
    end

    head :created
  end

  def create
    client.send_text_custom(params[:weixin_id], params[:q])

    head :created
  end

  private
    def set_access_control_headers 
      headers['Access-Control-Allow-Origin'] = Rails.application.config.meteor_server 
      headers['Access-Control-Request-Method'] = '*' 
    end

    def client
      @clients ||= {}
      @clients[params[:gh_id]] ||= connect_client
    end

    def connect_client
      account = Account.where(gh_id: params[:gh_id]).first
      WeixinAuthorize::Client.new(account.app_id, account.app_secret)
    end
end

class AccountsController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  after_filter :set_access_control_headers

  # POST /accounts
  def create
    account = Account.where({gh_id: params[:gh_id]}).first
    if account
      account.update(account_params)
    else
      attrs = account_params

      id = BSON::ObjectId.new
      attrs[:_id] = id.to_s

      Account.create(attrs)
    end
    
    head :created
  end

  private
    def set_access_control_headers
      headers['Access-Control-Allow-Origin'] = Rails.application.config.meteor_server
      headers['Access-Control-Request-Method'] = '*'
    end

    def account_params
      params.permit(:name, :gh_id, :weixin_id, :app_id, :app_secret, :user_id)
    end
end

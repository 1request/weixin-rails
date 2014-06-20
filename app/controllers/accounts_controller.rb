class AccountsController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  after_filter :set_access_control_headers

  # POST /accounts
  def create
    account = Account.where({weixin_id: params[:weixin_id]}).first
    if account
      account.update(account_params)
    else
      Account.create(account_params)
    end
    
    head :created
  end

  private
    def set_access_control_headers
      headers['Access-Control-Allow-Origin'] = 'http://localhost:4000'
      headers['Access-Control-Request-Method'] = '*'
    end

    def account_params
      params.permit(:weixin_id, :name, :app_id, :app_secret)
    end
end

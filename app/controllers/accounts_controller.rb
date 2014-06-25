class AccountsController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  after_filter :set_access_control_headers

  # POST /accounts
  def create
    account = Account.where({gh_id: params[:gh_id]}).first
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
      params.permit(:name, :gh_id, :weixin_id, :app_id, :app_secret)
    end
end

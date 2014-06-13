class ApisController < ApplicationController
  def index
    @weixin_secret_key = WeixinRailsMiddleware.config.weixin_secret_string
    @weixin_token = WeixinRailsMiddleware.config.weixin_token_string
  end
end

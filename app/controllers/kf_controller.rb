class KfController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  after_filter :set_access_control_headers

  def create
    client ||= WeixinAuthorize::Client.new("wxe2e163d3337f28ee", "0ce603e4068fd1f8ee5ef324473d5687")
    client.send_text_custom('oPPmst_BGsqMrhi-8kV56kdQ7E40', params[:q])

    head :created
  end

  def set_access_control_headers 
    headers['Access-Control-Allow-Origin'] = 'http://localhost:4000' 
    headers['Access-Control-Request-Method'] = '*' 
  end


end

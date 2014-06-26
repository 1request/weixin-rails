class ApisController < ApplicationController
  def index
    @accounts = Account.all
  end
end

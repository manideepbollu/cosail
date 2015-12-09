class SessionsController < ApplicationController

  layout 'login'
  before_action :authenticate_user!, :except => [:new]

  def new
  end

end

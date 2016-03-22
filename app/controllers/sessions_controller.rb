class SessionsController < ApplicationController
  layout 'layouts/narrow'

  def new
  end

  def create
    user_data = params.fetch('user', {})

    if (user_data['username'].blank? || user_data['password'].blank?)
      flash[:alert] = 'Username or password cannot be blank.'
    else
      authenticate!
    end

    redirect_to :root
  end

  def destroy
    warden.logout
    redirect_to :root
  end
end
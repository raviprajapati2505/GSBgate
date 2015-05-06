class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update]

  def index
    @users = User.where("role != ? OR role is null", User.roles[:admin])
  end

  def edit
  end

  def update
    if @user.update_without_password(user_params)
      flash[:notice] = 'Successfully updated user.'
      redirect_to users_path
    else
      render action: 'edit'
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :role)
  end
end

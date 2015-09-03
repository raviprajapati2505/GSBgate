class UsersController < AuthenticatedController
  before_action :set_user, only: [:edit, :update]
  load_and_authorize_resource

  def index
    @users = User.all
  end

  def edit
    @page_title = "Edit user #{@user.email}"
  end

  def update
    if @user.id == 1
      flash.now[:alert] = 'This system user cannot be changed.'
      render action: 'edit'
      return
    end
    if @user.update_without_password(user_params)
      redirect_to users_path, notice: 'Successfully updated user.'
    else
      render action: 'edit'
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
      @controller_model = @user
    end

    def user_params
      params.require(:user).permit(:email, :role)
    end
end

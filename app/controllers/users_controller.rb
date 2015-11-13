class UsersController < AuthenticatedController
  load_and_authorize_resource :user
  before_action :set_controller_model, except: [:new, :create, :index]

  def index
  end

  def edit
    @page_title = "Edit user #{@user.email}"
  end

  def update
    if @user.update_without_password(user_params)
      redirect_to users_path, notice: 'Successfully updated user.'
    else
      render action: 'edit'
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @user, status: :ok }
    end
  end

  private

  def set_controller_model
    @controller_model = @user
  end

  def user_params
    params.require(:user).permit(:email, :role)
  end
end

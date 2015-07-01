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
      flash[:alert] = 'This system user cannot be changed.'
      render action: 'edit'
      return
    end
    if @user.update_without_password(user_params)
      flash[:notice] = 'Successfully updated user.'
      redirect_to users_path
    else
      render action: 'edit'
    end
  end

  def new_member
    if params.has_key?(:project_id) && params.has_key?(:q) && params.has_key?(:page)
      project = Project.find(params[:project_id])
      # .where.not('exists(select id from project_authorizations where user_id = users.id and project_id = ?)', params[:project_id])
      total_count = User.where('email like ?', '%' + params[:q] + '%').without_permissions_for_project(project).count
      # .where.not('exists(select id from project_authorizations where user_id = users.id and project_id = ?)', params[:project_id])
      items = User.select('id, email as text')
                  .where('email like ?', '%' + params[:q] + '%')
                  .order(email: :asc)
                  .paginate(page: params[:page], per_page: 25)
                       .without_permissions_for_project(project)
      render json: {total_count: total_count, items: items}
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

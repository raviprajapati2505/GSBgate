class SchemeMixesController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  before_action :set_controller_model, except: [:new, :create]

  def show
    @page_title = @scheme_mix.full_name
  end

  def edit

  end

  def update
    # Check if other scheme mixes with same scheme_id exist
    # and if this custom_name is blank or the custom_name is already used
    identical_scheme_mixes = @certification_path.scheme_mixes.where(scheme_id: @scheme_mix.scheme_id);
    if identical_scheme_mixes.count > 1
      if params[:scheme_mix][:custom_name].blank?
        redirect_to(project_certification_path_path(@project, @certification_path), alert: 'Custom name cannot be blank.')
        return
      end
      identical_scheme_mixes.each do |scheme_mix|
        if scheme_mix.id != params[:id].to_i && scheme_mix.custom_name == params[:scheme_mix][:custom_name]
          redirect_to(project_certification_path_path(@project, @certification_path), alert: 'Custom name must be unique among rows with same scheme name.')
          return
        end
      end
    elsif params[:scheme_mix][:custom_name].blank?
      params[:scheme_mix][:custom_name] = nil
    end

    if @scheme_mix.update(scheme_mix_params)
      redirect_to(project_certification_path_path(@project, @certification_path), notice: 'Successfully changed scheme name.')
    else
      redirect_to(project_certification_path_path(@project, @certification_path), alert: 'Failed to change scheme name.')
    end
  end

  private
  def set_controller_model
    @controller_model = @scheme_mix
  end

  def scheme_mix_params
    params.require(:scheme_mix).permit(:custom_name)
  end
end

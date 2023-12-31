class SchemeMixesController < AuthenticatedController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project
  load_and_authorize_resource :scheme_mix, :through => :certification_path
  before_action :set_controller_model, except: [:new, :create]

  def show
    @page_title = ERB::Util.html_escape(@project.name.to_s)
    # creating hash with key = category.id and value = hash with category and its linked criteria
    @category_criterion_map = {}
    scheme_mix_criteria = @scheme_mix.scheme_mix_criteria.joins(:scheme_criterion).accessible_by(current_ability).order('scheme_criteria.number').map { |scheme_mix_criterion| scheme_mix_criterion.visible_status }
    scheme_mix_criteria.each do |scheme_mix_criterion|
      unless @category_criterion_map.has_key?(scheme_mix_criterion.scheme_criterion.scheme_category.id)
        @category_criterion_map[scheme_mix_criterion.scheme_criterion.scheme_category.id] = {category: scheme_mix_criterion.scheme_criterion.scheme_category, scheme_mix_criteria: []}
      end
      @category_criterion_map[scheme_mix_criterion.scheme_criterion.scheme_category.id][:scheme_mix_criteria] << scheme_mix_criterion
    end
    @category_criterion_map = @category_criterion_map.sort_by {|key, value| value[:category].display_weight }
  end

  def edit

  end

  def update
    # Check if other scheme mixes with same scheme_id exist
    # and if this custom_name is blank or the custom_name is already used
    identical_scheme_mixes = @certification_path.scheme_mixes.where(scheme_id: @scheme_mix.scheme_id)
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

  def download_scores_report
    filepath = filepath_for_report 'Criteria Summary for ' + @scheme_mix.name
    report = Reports::CriteriaScores.new(@scheme_mix)
    report.save_as(filepath)
    send_file filepath, :type => 'application/pdf', :x_sendfile => true
    # response.headers['X-Sendfile'] = filepath
    # response.headers['Content-Length'] = '0'
    # response.headers['Content-Type'] = 'application/pdf'
    # render body: nil, status: :ok
  end

  private
  def set_controller_model
    @controller_model = @scheme_mix
  end

  def scheme_mix_params
    params.require(:scheme_mix).permit(:custom_name)
  end

  def filepath_for_report(report_name)
    filename = "#{@project.code} - #{@certification_path.certificate.full_name} - #{report_name}.pdf"
    # "#{ENV['SHARED_PATH']}/private/projects/#{@certification_path.project.id.to_s}/certification_paths/#{@certification_path.id.to_s}/reports/#{filename}"
    "#{File.realpath('private/projects')}/#{@certification_path.project.id.to_s}/certification_paths/#{@certification_path.id.to_s}/reports/#{filename}"
  end
end

class ProjectsController < AuthenticatedController
  include ApplicationHelper
  include ActionView::Helpers::TranslationHelper
  load_and_authorize_resource :project, except: [:country_locations, :country_city_districts, :projects_statistics]
  before_action :set_controller_model, except: [:new, :create, :index, :projects_statistics]

  def index
    respond_to do |format|
      format.html {
        @page_title = t('projects.index.title_html')
        @datatable = Effective::Datatables::ProjectsCertificationPaths.new
      }
      format.json {
        if (params.has_key?(:limit))
          limit = params[:limit]
        else
          limit = 100
        end
        if (params.has_key?(:offset))
          offset = params[:offset]
        else
          offset = 0
        end

        project_at = Project.arel_table
        certification_path_at = CertificationPath.arel_table
        cert_path_join_on = project_at.create_on(project_at[:id].eq(certification_path_at[:project_id]))
        cert_path_outer_join = project_at.create_join(certification_path_at, cert_path_join_on, Arel::Nodes::OuterJoin)

        certification_path_status_at = CertificationPathStatus.arel_table
        cert_path_status_join_on = certification_path_at.create_on(certification_path_at[:certification_path_status_id].eq(certification_path_status_at[:id]))
        cert_path_status_outer_join = certification_path_at.create_join(certification_path_status_at, cert_path_status_join_on, Arel::Nodes::OuterJoin)

        certificate_at = Certificate.arel_table
        cert_join_on = certification_path_at.create_on(certification_path_at[:certificate_id].eq(certificate_at[:id]))
        cert_outer_join = certification_path_at.create_join(certificate_at, cert_join_on, Arel::Nodes::OuterJoin)

        development_type_at = DevelopmentType.arel_table
        dev_type_join_on = certification_path_at.create_on(certification_path_at[:development_type_id].eq(development_type_at[:id]))
        dev_type_outer_join = certification_path_at.create_join(development_type_at, dev_type_join_on, Arel::Nodes::OuterJoin)

        scheme_mix_at = SchemeMix.arel_table
        scheme_mix_join_on = certification_path_at.create_on(certification_path_at[:id].eq(scheme_mix_at[:certification_path_id]))
        scheme_mix_outer_join = certification_path_at.create_join(scheme_mix_at, scheme_mix_join_on, Arel::Nodes::OuterJoin)

        scheme_at = Scheme.arel_table
        scheme_join_on = scheme_mix_at.create_on(scheme_mix_at[:scheme_id].eq(scheme_at[:id]))
        scheme_outer_join = scheme_mix_at.create_join(scheme_at, scheme_join_on, Arel::Nodes::OuterJoin)

        result_set = Project.select('projects.id as project_id')
                       .select('projects.name as project_name')
                       .select('projects.address as project_address')
                       .select('projects.location as project_location')
                       .select('projects.country as project_country')
                       .select('projects.coordinates as project_coordinates')
                       .select('projects.gross_area as project_gross_area')
                       .select('projects.certified_area as project_certified_area')
                       .select('projects.buildings_footprint_area as project_buildings_footprint_area')
                       .select('projects.carpark_area as project_carpark_area')
                       .select('projects.project_site_area as project_site_area')
                       .select('certification_paths.id as certification_path_id')
                       .select('certification_paths.project_id as certification_path_project_id')
                       .select('certification_paths.certificate_id as certification_path_certificate_id')
                       .select('certification_paths.certification_path_status_id as certification_path_certification_path_status_id')
                       .select('certification_paths.development_type_id as certification_path_development_type_id')
                       .select('(%s) AS total_targeted_score' % Effective::Datatables::ProjectsCertificationPaths.query_score_in_certificate_points(:targeted_score))
                       .select('(%s) AS total_submitted_score' % Effective::Datatables::ProjectsCertificationPaths.query_score_in_certificate_points(:submitted_score))
                       .select('(%s) AS total_achieved_score' % Effective::Datatables::ProjectsCertificationPaths.query_score_in_certificate_points(:achieved_score))
                       .select('certificates.id as certificate_id')
                       .select('certificates.name as certificate_name')
                       .select('certificates.gsb_version as certificate_gsb_version')
                       .select('certification_path_statuses.id as certification_path_status_id')
                       .select('certification_path_statuses.name as certification_path_status_name')
                       .select('development_types.id as development_type_id')
                       .select('development_types.name as development_type_name')
                       .select('scheme_mixes.id as scheme_mix_id')
                       .select('scheme_mixes.certification_path_id as scheme_mix_certification_path_id')
                       .select('scheme_mixes.scheme_id as scheme_mix_scheme_id')
                       .select('scheme_mixes.weight as scheme_mix_weight')
                       .select('schemes.id as scheme_id')
                       .select('schemes.name as scheme_name')
                       .joins(cert_path_outer_join)
                       .joins(cert_outer_join)
                       .joins(cert_path_status_outer_join)
                       .joins(dev_type_outer_join)
                       .joins(scheme_mix_outer_join)
                       .joins(scheme_outer_join)
                       .order('projects.id ASC')
                       .limit(limit)
                       .offset(offset)

        if current_ability.nil?
          result_set = result_set.none
        else
          #   use cancan ability to limit the authorized projects
          result_set = result_set.accessible_by(current_ability)
        end

        projects = []
        result_set.each do |result|
          # project
          p_i = projects.index{ |p| p[:id] == result.project_id }
          if p_i.nil?
            project = {}
            projects.push(project)
            project[:id] = result.project_id
            project[:name] = result.project_name
            project[:address] = result.project_address
            project[:location] = result.project_location
            project[:country] = result.project_country
            project[:latitude] = result.coordinates.split(',')[0]
            project[:longitude] = result.coordinates.split(',')[1]
            project[:gross_area] = result.project_gross_area
            project[:certified_area] = result.project_certified_area
            project[:buildings_footprint_area] = result.project_buildings_footprint_area
            project[:carpark_area] = result.project_carpark_area
            project[:project_site_area] = result.project_site_area
            project[:certification_paths] = []
          else
            project = projects[p_i]
          end

          unless result.certification_path_id.nil?

            # certification path
            cp_i = project[:certification_paths].index{ |cp| cp[:id] == result.certification_path_id }
            if cp_i.nil?
              certification_path = {}
              if project[:certification_paths].nil?
                project[:certification_paths] = []
              end
              project[:certification_paths].push(certification_path)
              certification_path[:id] = result.certification_path_id
              certification_path[:total_targeted_score] = result.total_targeted_score
              certification_path[:total_submitted_score] = result.total_submitted_score
              certification_path[:total_achieved_score] = result.total_achieved_score
              certification_path[:scheme_mixes] = []

              # certificate
              certificate = {}
              certification_path[:certificate] = certificate
              certificate[:id] = result.certificate_id
              certificate[:name] = result.certificate_name
              certificate[:gsb_version] = result.certificate_gsb_version

              # certification path status
              certification_path_status = {}
              certification_path[:certification_path_status] = certification_path_status
              certification_path_status[:id] = result.certification_path_status_id
              certification_path_status[:name] = result.certification_path_status_name

              # development type
              development_type = {}
              certification_path[:development_type] = development_type
              development_type[:id] = result.development_type_id
              development_type[:name] = result.development_type_name
            else
              certification_path = project[:certification_paths][cp_i]
            end

            # scheme mix
            sm_i = certification_path[:scheme_mixes].index{ |sm| sm[:id] == result.scheme_mix_id }
            if sm_i.nil?
              scheme_mix = {}
              if certification_path[:scheme_mixes].nil?
                certification_path[:scheme_mixes] = []
              end
              certification_path[:scheme_mixes].push(scheme_mix)
              scheme_mix[:id] = result.scheme_mix_id
              scheme_mix[:weight] = result.scheme_mix_weight

              # scheme
              scheme = {}
              scheme_mix[:scheme] = scheme
              scheme[:id] = result.scheme_id
              scheme[:name] = result.scheme_name
            end

          end
        end

        render json: projects, status: :ok
      }
    end
  end

  def projects_statistics
    @page_title = t('projects.projects_statistics.title_html')

    projects = Project.datatable_projects_records

    projects = 
      if current_user.is_service_provider?
        project_ids = Project.accessible_by(current_ability).pluck(:id)
        projects.where(id: project_ids.uniq)
      else
        projects.accessible_by(current_ability)
      end
      
    offline_projects = Offline::Project.datatable_projects_records

    @projects = []
    
    certification_paths = 
      CertificationPath.eager_load(
        :certificate, 
        scheme_mixes: :scheme
      ).where(
        id: projects.pluck('certification_paths.id')
      )

    # for general projects
    general_projects_lables = 
      [
        t('models.effective.datatables.projects.lables.project_code'),
        t('models.effective.datatables.projects.lables.project_name'),
        t('models.effective.datatables.projects.lables.project_certified_area'),
        t('models.effective.datatables.projects.lables.project_site_area'),
        t('models.effective.datatables.projects.lables.owner'),
        t('models.effective.datatables.projects.lables.developer'),
        t('models.effective.datatables.projects.lables.project_gross_area'),
        t('models.effective.datatables.projects.lables.project_country'),
        t('models.effective.datatables.projects.lables.project_city'),
        t('models.effective.datatables.projects.lables.project_district'),
        t('models.effective.datatables.projects.lables.project_owner_business_sector'),
        t('models.effective.datatables.projects.lables.project_developer_business_sector'),
        t('models.effective.datatables.projects_certification_paths.rating.label'),
        t('models.effective.datatables.projects_certification_paths.assessment_method.label'),
        t('models.effective.datatables.projects.lables.construction_year'),
        t('models.effective.datatables.projects_certification_paths.certificate_id.label'),
        t('models.effective.datatables.projects_certification_paths.certificate_stage.label'),
        t('models.effective.datatables.projects_certification_paths.certificate_version.label'),
        t('models.effective.datatables.projects_certification_paths.certification_path_development_type.label'),
        t('models.effective.datatables.projects_certification_paths.certification_path_certification_path_status_id.label'),
        t('models.effective.datatables.projects_certification_paths.certification_path_certified_at.label'),
        t('models.effective.datatables.projects_certification_paths.certification_scheme_name.label'),
        t('models.effective.datatables.projects_certification_paths.schemes_array.label'),
        t('models.effective.datatables.projects_certification_paths.certification_path_started_at.label'),
        t('models.effective.datatables.projects_certification_paths.certification_path_status_is_active.label'),
        t('models.effective.datatables.projects_certification_paths.certification_path_pcr_track.label'),
        t('models.effective.datatables.projects_certification_paths.building_types.label'),
        t('models.effective.datatables.projects.lables.service_provider')
      ]
    projects.each do |data|
      certification_path = certification_paths.find { |cp| cp.id == data.certification_path_id }
      certificate = certification_path&.certificate

      formatted_data = 
        [
          data.project_code,
          data.project_name,
          data.project_certified_area,
          data.project_site_area,
          data.project_owner,
          data.project_developer,
          data.project_gross_area,
          data.project_country,
          data.project_city,
          data.project_district,
          data.project_owner_business_sector,
          data.project_developer_business_sector,

          "#{
              unless data.certification_path_status_is_active 
                if certification_path.present?
                  if certification_path.is_checklist_method?

                    if data.certificate_type&.to_i == 3
                      rating = 
                        if data.certification_path_status_name == "Certified"
                          'CERTIFIED'
                        elsif data.certification_path_status_name == "Not certified"
                          'CERTIFICATION DENIED'
                        else
                          ""
                        end
                    end

                  else 
                    scores = data.total_achieved_score 
                    
                    rating = 
                      certification_path
                        .rating_for_score(
                          scores, 
                          certificate: certificate, 
                          certificate_gsb_version: data.certificate_gsb_version, certificate_name: data.certificate_name
                        ) 
                  end
                  
                else 
                  rating = -1 
                end 
              end

              rating = 
                if ['1', '2', '3', '4', '5', '6'].include?(rating&.to_s)
                  rating_string = []
                  rating.to_i.times do
                    rating_string.push('*')
                  end

                  rating_string.join(' ')
                else
                  rating
                end
          }",

          "#{
              if certification_path.present?
                certification_path.assessment_method_title
              end
          }",

          data.project_construction_year,
          
          "#{
              if certificate.present?
                certificate&.only_certification_name
              end
          }",
                                                                                                
          "#{
              if certificate.present?
                certificate&.name
              end
          }",
                                                                                                      
          "#{
              if certificate.present?
                certificate&.only_version
              end
          }",

          "#{
              case data.certification_scheme_name
              when 'Parks'
                'Parks'
              when 'Fitout'
                'Single Zone, Fitout'
              else
                data.development_type_name
              end
          }",

          "#{ 
              if data.certification_path_status_name == "Certificate In Process"
                "Certificate Generated"
              else
                data.certification_path_status_name
              end
          }",
                                                                                                                                  
          data.certification_path_certified_at&.to_date&.strftime('%e-%b-%y'),
          
          "#{
              if [3, 4].include?(data.certificate_type&.to_i) && ["Neighborhoods", "Mixed Use"].include?(data.development_type_name)
                data.development_type_name
              elsif data.development_type_name == "Districts"
                "Districts"
              else
                # rec.certification_scheme_name
                ERB::Util.html_escape(data.certification_scheme_name).split('|||').sort.join('<br/>') unless data.certification_scheme_name.nil?
              end
          }",
                                                                                                            
          "#{
              unless data.schemes_array.nil?
                schemes_array = ERB::Util.html_escape(data.schemes_array).split('|||').sort
                if schemes_array.size > 1
                  schemes_array.join('<br/>')
                end
              end
          }",

          data.certification_path_started_at&.to_date&.strftime('%e-%b-%y'),

          data.certification_path_status_is_active,

          data.certification_path_pcr_track,

          data.building_type_name,

          data.project_service_provider
        ]

      @projects.push(general_projects_lables.zip(formatted_data).to_h)
    end

    # for offiline projects
    offline_projects_lables = 
      [
        t('models.effective.datatables.projects.lables.project_code'), 
        t('models.effective.datatables.projects.lables.project_name'), 
        t('models.effective.datatables.offline.project.certificate_type'),
        t('models.effective.datatables.projects.lables.project_certified_area'),
        t('models.effective.datatables.offline.project.owner'),
        t('models.effective.datatables.offline.project.developer'),
        t('models.effective.datatables.offline.project.assessment_method'),
        t('models.effective.datatables.offline.project.construction_year'),
        t('models.effective.datatables.offline.project.project_country'),
        t('models.effective.datatables.offline.project.project_city'),
        t('models.effective.datatables.offline.project.project_district'),
        t('models.effective.datatables.offline.project.project_owner_business_sector'),
        t('models.effective.datatables.offline.project.project_developer_business_sector'),
        t('models.effective.datatables.offline.project.project_gross_built_up_area'),
        t('models.effective.datatables.offline.certification_path.name'),
        t('models.effective.datatables.offline.certification_path.version'),
        t('models.effective.datatables.offline.certification_path.development_type'),
        t('models.effective.datatables.offline.certification_path.status'),
        t('models.effective.datatables.offline.certification_path.certified_at'),
        t('models.effective.datatables.offline.certification_path.rating'),
        t('models.effective.datatables.offline.certification_path.schemes'),
        t('models.effective.datatables.offline.certification_path.subscheme'),
        t('models.effective.datatables.offline.project.plot_area')
      ]
  end

  def show
    respond_to do |format|
      format.html {
        @page_title = ERB::Util.html_escape(@project.name.to_s)
        @certification_path = CertificationPath.new(project: @project)
        @projects_user = ProjectsUser.new(project: @project)
        @projects_surveys = @project.projects_surveys
      }

      format.json { render json: @project, status: :ok }
    end
  end

  def show_tools
    authorize! :show_tools, @project
  end

  def new
    @page_title = 'New project'
    @project = Project.new
    @project.service_provider = current_user.organization_name
    @project.service_provider_2 = current_user.organization_name
    @certificates = Certificate.all
  end

  def edit
    @page_title = "Edit #{ERB::Util.html_escape(@project.name.to_s)}"
    @certificates = Certificate.all
  end

  def create
    @project = Project.new(project_params)
    unless project_params.has_key?(:service_provider)
      @project.service_provider = current_user.organization_name
    end
    @project.transaction(joinable:false) do
      if @project.save
        @project.transaction(requires_new: true, joinable: false) do
          certification_team_type = ProjectsUser.certification_team_types[:other]
          projects_user = ProjectsUser.new(project: @project, user: current_user, role: ProjectsUser.roles[:cgp_project_manager], certification_team_type: certification_team_type)
          if projects_user.save
            redirect_to @project, notice: 'Project was successfully created.'
            return
          end
          render :new
        end
      else
        render :new
      end
    end
  end

  def update
    respond_to do |format|
      params[:project][:location_plan_file] = @project.location_plan_file unless params[:project].has_key?(:location_plan_file) && params[:project][:location_plan_file].present?
      params[:project][:site_plan_file] = @project.site_plan_file unless params[:project].has_key?(:site_plan_file) && params[:project][:site_plan_file].present?
      params[:project][:design_brief_file] = @project.design_brief_file unless params[:project].has_key?(:design_brief_file) && params[:project][:design_brief_file].present?
      params[:project][:project_narrative_file] = @project.project_narrative_file unless params[:project].has_key?(:project_narrative_file) && params[:project][:project_narrative_file].present?
      params[:project][:sustainability_features_file] = @project.sustainability_features_file unless params[:project].has_key?(:sustainability_features_file) && params[:project][:sustainability_features_file].present?
      params[:project][:area_statement_file] = @project.area_statement_file unless params[:project].has_key?(:area_statement_file) && params[:project][:area_statement_file].present?

      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def download_location_plan
    authorize! :download_location_plan, @project
    begin
      send_file @project.location_plan_file.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This document is no longer available for download. This could be due to a detection of malware.')
    end
  end

  def download_site_plan
    authorize! :download_site_plan, @project
    begin
      send_file @project.site_plan_file.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This document is no longer available for download. This could be due to a detection of malware.')
    end
  end

  def download_design_brief
    authorize! :download_design_brief, @project
    begin
      send_file @project.design_brief_file.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This document is no longer available for download. This could be due to a detection of malware.')
    end
  end

  def download_project_narrative
    authorize! :download_project_narrative, @project
    begin
      send_file @project.project_narrative_file.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This document is no longer available for download. This could be due to a detection of malware.')
    end
  end

  def download_sustainability_features
    authorize! :download_sustainability_features, @project
    begin
      send_file @project.sustainability_features_file.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This document is no longer available for download. This could be due to a detection of malware.')
    end
  end

  def download_area_statement
    authorize! :download_area_statement, @project
    begin
      send_file @project.area_statement_file.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This document is no longer available for download. This could be due to a detection of malware.')
    end
  end

  def confirm_destroy
  end

  def destroy
    if @project.destroy
      redirect_to projects_path, notice: 'The project was successfully removed.'
    else
      redirect_to project_path, alert: 'An error occurred when trying to remove the project. Please try again later.'
    end
  end

  def country_locations
    @location = Location.find_by_country(params["country"])
    @district = District.find_by_country(params["country"])
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def country_city_districts
    @district = District.find_by_country(params["country"])
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  private
  def set_controller_model
    @controller_model = @project
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    if current_user.is_system_admin?  || current_user.is_gsb_trust_admin?
      params.require(:project).permit(:name, :certificate_type, :owner, :developer, :service_provider, :service_provider_2, :description, :address, :city, :district, :location, :country, :construction_year, :coordinates, :buildings_footprint_area, :gross_area, :certified_area, :carpark_area, :project_site_area, :terms_and_conditions_accepted, :location_plan_file, :location_plan_file_cache, :site_plan_file, :site_plan_file_cache, :design_brief_file, :design_brief_file_cache, :project_narrative_file, :project_narrative_file_cache, :sustainability_features_file, :sustainability_features_file_cache, :area_statement_file, :area_statement_file_cache, :building_type_group_id, :building_type_id, :estimated_project_cost, :cost_square_meter, :estimated_building_cost, :estimated_infrastructure_cost, :code, :project_owner_business_sector, :project_developer_business_sector, :project_owner_email, :specify_other_project_use)
    else
      params.require(:project).permit(:name, :certificate_type, :owner, :developer, :service_provider, :service_provider_2, :description, :address, :city, :district, :location, :country, :construction_year, :coordinates, :buildings_footprint_area, :gross_area, :certified_area, :carpark_area, :project_site_area, :terms_and_conditions_accepted, :location_plan_file, :location_plan_file_cache, :site_plan_file, :site_plan_file_cache, :design_brief_file, :design_brief_file_cache, :project_narrative_file, :project_narrative_file_cache, :sustainability_features_file, :sustainability_features_file_cache, :area_statement_file, :area_statement_file_cache, :building_type_group_id, :building_type_id, :estimated_project_cost, :cost_square_meter, :estimated_building_cost, :estimated_infrastructure_cost, :project_owner_business_sector, :project_developer_business_sector, :project_owner_email, :specify_other_project_use)
    end
  end
end

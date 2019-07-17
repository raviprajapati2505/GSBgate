class Api::V1::ProjectsController < Api::ApiController
  # load_and_authorize_resource
  # load_resource

  # curl -v -H "Accept: application/json" -H "Authorization: Bearer ..." "http://localhost:3000/api/v1/projects"
  def index
    limit = 100

    # restrict to Operations projects
    query = Project.accessible_by(current_ability).joins(certification_paths: [:certificate]).where(certification_paths: {certification_path_status_id: CertificationPathStatus::CERTIFIED}, certificates: {certificate_type: Certificate::certificate_types[:operations_type], gsas_version: '2019'})
    total_energy_consumption_query = SchemeMixCriterionEpl.accessible_by(current_ability).joins(scheme_mix_criterion: [scheme_mix: [:scheme, certification_path: [:certificate, :project]]]).where(certificates: {certificate_type: Certificate::certificate_types[:operations_type]}).unscope(:order)
    total_water_consumption_query = SchemeMixCriterionWpl.accessible_by(current_ability).joins(scheme_mix_criterion: [scheme_mix: [:scheme, certification_path: [:certificate, :project]]]).where(certificates: {certificate_type: Certificate::certificate_types[:operations_type]}).unscope(:order)
    if params.has_key?(:filter)
      filter = Hash[URI.decode_www_form(params[:filter])]
      # provide total count of projects with the same band for EPL/WPL
      # provide total energy/water consumption
      # provide subtotal energy/water consumption (breakdown subitem ?)
      # provide average energy/water consumption

      # Filter EPL/WPL band
      if filter.has_key?('EPL_band_asbuilt')
        query = query.where("EXISTS(#{SchemeMixCriterionEpl.joins(scheme_mix_criterion: [:scheme_mix]).where('scheme_criterion_performance_labels.label = \'As Built\' AND scheme_mixes.certification_path_id = certification_paths.id').where(band: filter['EPL_band_asbuilt']).unscope(:order).to_sql})")
        total_energy_consumption_query = total_energy_consumption_query.where('scheme_criterion_performance_labels.label = \'As Built\' AND scheme_mix_criterion_performance_labels.band = ?', filter['EPL_band_asbuilt'])
        total_water_consumption_query = total_water_consumption_query.where("EXISTS(#{SchemeMixCriterionEpl.joins(scheme_mix_criterion: [:scheme_mix]).where('scheme_criterion_performance_labels.label = \'As Built\' AND scheme_mixes.certification_path_id = certification_paths.id').where(band: filter['EPL_band_asbuilt']).unscope(:order).to_sql})")
      end
      if filter.has_key?('EPL_band_asoperated')
        query = query.where("EXISTS(#{SchemeMixCriterionEpl.joins(scheme_mix_criterion: [:scheme_mix]).where('scheme_criterion_performance_labels.label = \'As Operated\' AND scheme_mixes.certification_path_id = certification_paths.id').where(band: filter['EPL_band_asoperated']).unscope(:order).to_sql})")
        total_energy_consumption_query = total_energy_consumption_query.where('scheme_criterion_performance_labels.label = \'As Operated\' AND scheme_mix_criterion_performance_labels.band = ?', filter['EPL_band_asoperated'])
        total_water_consumption_query = total_water_consumption_query.where("EXISTS(#{SchemeMixCriterionEpl.joins(scheme_mix_criterion: [:scheme_mix]).where('scheme_criterion_performance_labels.label = \'As Operated\' AND scheme_mixes.certification_path_id = certification_paths.id').where(band: filter['EPL_band_asoperated']).unscope(:order).to_sql})")
      end
      if filter.has_key?('WPL_band_asbuilt')
        query = query.where("EXISTS(#{SchemeMixCriterionWpl.joins(scheme_mix_criterion: [:scheme_mix]).where('scheme_criterion_performance_labels.label = \'As Built\' AND scheme_mixes.certification_path_id = certification_paths.id').where(band: filter['WPL_band_asbuilt']).unscope(:order).to_sql})")
        total_energy_consumption_query = total_energy_consumption_query.where('scheme_criterion_performance_labels.label = \'As Built\' AND scheme_mix_criterion_performance_labels.band = ?', filter['WPL_band_asbuilt'])
        total_water_consumption_query = total_water_consumption_query.where("EXISTS(#{SchemeMixCriterionWpl.joins(scheme_mix_criterion: [:scheme_mix]).where('scheme_criterion_performance_labels.label = \'As Built\' AND scheme_mixes.certification_path_id = certification_paths.id').where(band: filter['WPL_band_asbuilt']).unscope(:order).to_sql})")
      end
      if filter.has_key?('WPL_band_asoperated')
        query = query.where("EXISTS(#{SchemeMixCriterionWpl.joins(scheme_mix_criterion: [:scheme_mix]).where('scheme_criterion_performance_labels.label = \'As Operated\' AND scheme_mixes.certification_path_id = certification_paths.id').where(band: filter['WPL_band_asoperated']).unscope(:order).to_sql})")
        total_energy_consumption_query = total_energy_consumption_query.where('scheme_criterion_performance_labels.label = \'As Operated\' AND scheme_mix_criterion_performance_labels.band = ?', filter['WPL_band_asoperated'])
        total_water_consumption_query = total_water_consumption_query.where("EXISTS(#{SchemeMixCriterionWpl.joins(scheme_mix_criterion: [:scheme_mix]).where('scheme_criterion_performance_labels.label = \'As Operated\' AND scheme_mixes.certification_path_id = certification_paths.id').where(band: filter['WPL_band_asoperated']).unscope(:order).to_sql})")
      end
      # filter on typology (= scheme ?)
      if filter.has_key?('typology')
        query = query.joins(certification_paths: [:schemes]).where('schemes.name like ?', "%#{filter['typology']}%")
        total_energy_consumption_query = total_energy_consumption_query.where('schemes.name like ?', "%#{filter['typology']}%")
        total_water_consumption_query = total_water_consumption_query.where('schemes.name like ?', "%#{filter['typology']}%")
      end
      if filter.has_key?('country')
        query = query.where('country like ?', "%#{filter['country']}%")
        total_energy_consumption_query = total_energy_consumption_query.where('projects.country like ?', "%#{filter['country']}%")
        total_water_consumption_query = total_water_consumption_query.where('projects.country like ?', "%#{filter['country']}%")
      end
      # extra filters which we thought where interesting
      if filter.has_key?('owner')
        query = query.where('owner like ?', "%#{filter['owner']}%")
        total_energy_consumption_query = total_energy_consumption_query.where('projects.owner like ?', "%#{filter['owner']}%")
        total_water_consumption_query = total_water_consumption_query.where('projects.owner like ?', "%#{filter['owner']}%")
      end
      if filter.has_key?('construction_year')
        query = query.where('construction_year = ?', filter['construction_year'])
        total_energy_consumption_query = total_energy_consumption_query.where('projects.construction_year = ?', filter['construction_year'])
        total_water_consumption_query = total_water_consumption_query.where('projects.construction_year = ?', filter['construction_year'])
      end
      if filter.has_key?('certified_at_year')
        query = query.where('DATE_PART(\'year\', certification_paths.certified_at) = ?', filter['certified_at_year'])
        total_energy_consumption_query = total_energy_consumption_query.where('DATE_PART(\'year\', certification_paths.certified_at) = ?', filter['certified_at_year'])
        total_water_consumption_query = total_water_consumption_query.where('DATE_PART(\'year\', certification_paths.certified_at) = ?', filter['certified_at_year'])
      end
    end
    # @total_energy_consumption = total_energy_consumption_query.sum('scheme_mix_criterion_performance_labels.cooling + scheme_mix_criterion_performance_labels.lighting + scheme_mix_criterion_performance_labels.auxiliaries + scheme_mix_criterion_performance_labels.dhw + scheme_mix_criterion_performance_labels.others + scheme_mix_criterion_performance_labels.generation')
    @total_cooling_consumption = total_energy_consumption_query.sum('scheme_mix_criterion_performance_labels.cooling')
    @total_lighting_consumption = total_energy_consumption_query.sum('scheme_mix_criterion_performance_labels.lighting')
    @total_auxiliaries_consumption = total_energy_consumption_query.sum('scheme_mix_criterion_performance_labels.auxiliaries')
    @total_dhw_consumption = total_energy_consumption_query.sum('scheme_mix_criterion_performance_labels.dhw')
    @total_others_consumption = total_energy_consumption_query.sum('scheme_mix_criterion_performance_labels.others')
    @total_generation_consumption = total_energy_consumption_query.sum('scheme_mix_criterion_performance_labels.generation')

    # @total_water_consumption = total_water_consumption_query.sum('scheme_mix_criterion_performance_labels.indoor_use + scheme_mix_criterion_performance_labels.irrigation + scheme_mix_criterion_performance_labels.cooling_tower')
    @total_indoor_use_consumption = total_water_consumption_query.sum('scheme_mix_criterion_performance_labels.indoor_use')
    @total_irrigation_consumption = total_water_consumption_query.sum('scheme_mix_criterion_performance_labels.irrigation')
    @total_cooling_tower_consumption = total_water_consumption_query.sum('scheme_mix_criterion_performance_labels.cooling_tower')

    @project_count = query.count

    # pagination
    if params.has_key?(:page)
      @page = params[:page].to_i
      @page -= 1
    else
      @page = 0
    end
    offset = @page * limit
    # more = (offset + limit) < @@project_count
    @page_count = (@project_count + limit - 1) / limit

    # sorting
    if params.has_key?(:sort_by)
      sort_by = params[:sort_by]
      if params.has_key?(:sort_desc) && params[:sort_desc] == 'true'
        @projects = query.offset(offset).order("#{sort_by} desc").limit(limit)
      else
        @projects = query.offset(offset).order(sort_by).limit(limit)
      end
    else
      @projects = query.offset(offset).order('id').limit(limit)
    end

    render 'index', formats: :json
  end

  # curl -v -H "Accept: application/json" -H "Authorization: Bearer ..." "http://localhost:3000/api/v1/projects/<id>"
  def show
    @project = Project.accessible_by(current_ability).find_by(id: params[:id])
    if @project.nil?
      render json: {}, status: :not_found
    else
      render 'show', formats: :json
    end
  end

  def typologies
    query = Scheme.joins(development_types: [:certificate]).where(certificates: {certificate_type: Certificate::certificate_types[:operations_type]}, gsas_version: '2019')
    @typologies = query.distinct.order('id')
    render 'typologies', formats: :json
  end
end
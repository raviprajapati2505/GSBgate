class Api::V1::ProjectsController < Api::ApiController
  # load_and_authorize_resource
  # load_resource

  # curl -v -H "Accept: application/json" -H "Authorization: Bearer ..." "http://localhost:3000/api/v1/projects"
  def index
    limit = 100

    # restrict to Operations projects
    query = Project.accessible_by(current_ability).joins(certification_paths: [:certificate]).where(certificates: {certificate_type: Certificate::certificate_types[:operations_type]})
    if params.has_key?(:filter)
      filter = Hash[URI.decode_www_form(params[:filter])]
      # TODO provide total count of projects with the same band for EPL/WPL
      # TODO provide total energy/water consumption
      # TODO provide subtotal energy/water consumption (breakdown subitem ?)
      # TODO provide average energy/water consumption

      # TODO filter EPL/WPL band
      if filter.has_key?('EPL_band')
        # TODO not yet implemented
      end
      if filter.has_key?('WPL_band')
        # TODO not yet implemented
      end
      # filter on typology (= scheme ?)
      if filter.has_key?('typology')
        query = query.joins(certification_paths: [:schemes]).where('schemes.name like ?', "%#{filter['typology']}%")
      end
      if filter.has_key?('country')
        query = query.where('country like ?', "%#{filter['country']}%")
      end
      # extra filters which we thought where interesting
      if filter.has_key?('owner')
        query = query.where('owner like ?', "%#{filter['owner']}%")
      end
      if filter.has_key?('construction_year')
        query = query.where('construction_year = ?', filter['construction_year'])
      end
      if filter.has_key?('rating')
      #   TODO not yet implemented
      end
      if filter.has_key?('main_scheme')
      #   TODO not yet implemented
      end
    end
    @total_count = query.count

    # pagination
    if params.has_key?(:page)
      @page = params[:page].to_i
      @page -= 1
    else
      @page = 0
    end
    offset = @page * limit
    # more = (offset + limit) < @total_count
    @page_count = (@total_count + limit - 1) / limit

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
end
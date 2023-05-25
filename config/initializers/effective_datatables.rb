EffectiveDatatables.setup do |config|
  # Authorization Method
  #
  # This method is called by all controller actions with the appropriate action and resource
  # If it raises an exception or returns false, an Effective::AccessDenied Error will be raised
  #
  # Use via Proc:
  # Proc.new { |controller, action, resource| authorize!(action, resource) }       # CanCan
  # Proc.new { |controller, action, resource| can?(action, resource) }             # CanCan with skip_authorization_check
  # Proc.new { |controller, action, resource| authorize "#{action}?", resource }   # Pundit
  # Proc.new { |controller, action, resource| current_user.is?(:admin) }           # Custom logic
  #
  # Use via Boolean:
  # config.authorization_method = true  # Always authorized
  # config.authorization_method = false # Always unauthorized
  #
  # Use via Method (probably in your application_controller.rb):
  # config.authorization_method = :my_authorization_method
  # def my_authorization_method(resource, action)
  #   true
  # end
  config.authorization_method = Proc.new { |controller, action, resource| authorize!(action, resource) }

  # Default number of entries shown per page
  # Valid options are: 5, 10, 25, 50, 100, 250, 500, :all
  config.default_length = 25

  # Default class used on the <table> tag
  config.html_class = 'table table-bordered table-striped table-hover'

  # If a user has previously visited this page and is returning, use the cookie to restore last session
  # Irregardless of this setting, effective_datatables still uses a cookie to function
  config.save_state = true

  # When using the actions_column DSL method, apply the following behavior
  # Valid values for each action are:
  # true - display this action if authorized?(:show, Post)
  # false - do not display this action
  # :authorize - display this action if authorized?(:show, Post<3>)  (every instance is checked)
  #
  # You can override these defaults on a per-table basis
  # by calling `actions_column(show: false, edit: true, destroy: :authorize)`
  config.actions_column = {
    show: :authorize,
    edit: :authorize,
    destroy: :authorize,
    unarchive: :authorize
  }

  # Log search/sort information to the console
  config.debug = true

  # String size. Final byte size is about 1.5 times bigger, after rails signs it
  config.max_cookie_size = 2000
end

# Overrides Methods
Effective::EffectiveDatatable::Compute.module_eval do
  BLANK = ''.freeze

  private

  def compute
    col = collection

    # Assign total records
    @total_records = (active_record_collection? ? column_tool.size(col) : value_tool.size(col))

    # Apply scope
    col = column_tool.scope(col)

    # Apply column searching
    col = column_tool.search(col)
    @display_records = column_tool.size(col) unless value_tool.searched.present?

    # Apply column ordering
    col = column_tool.order(col)

    # Arrayize if we have value tool work to do
    col = arrayize(col) if value_tool.searched.present? || value_tool.ordered.present?

    # Apply value searching
    col = value_tool.search(col)
    @display_records = value_tool.size(col) if value_tool.searched.present?

    # Apply value ordering
    col = value_tool.order(col)

    # Write filtered & ordered data in tmp file for further use
    store_json_in_file(col)
    
    # Apply pagination
    col = col.kind_of?(Array) ? value_tool.paginate(col) : column_tool.paginate(col)

    # Arrayize the searched, ordered, paginated results
    col = arrayize(col) unless col.kind_of?(Array)

    # Assign display records
    @display_records ||= @total_records

    # Compute aggregate data
    @aggregates_data = aggregate(col) if _aggregates.present?

    # Charts too
    @charts_data = chart(col) if _charts.present?

    # Format all results
    format(col)

    # Finalize hook
    finalize(col)
  end

  def store_json_in_file(projects)
    begin
      base_path = File.join(Rails.root, 'tmp', 'projects_data')
      FileUtils.mkdir_p(base_path) unless File.exist?(base_path)
      filename = File.join(base_path, "project_data.json")

      File.open(filename, "w") do |f|
        f.write(projects.to_json)
      end

    rescue StandardError => e
      puts "-------------------- #{e.message} --------------------"
    end
  end
end

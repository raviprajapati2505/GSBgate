module ReportsHelper
  def certificate_name(name)
    text = "#{@certification_path.name} Criteria Summary \n #{@certification_path.project.name}"
  end
end
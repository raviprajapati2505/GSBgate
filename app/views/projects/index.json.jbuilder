json.array!(@projects) do |project|
  json.extract! project, :id, :name, :description, :project_status_id
  json.url project_url(project, format: :json)
end

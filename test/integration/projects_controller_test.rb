require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest

  test 'should get projects' do
    post api_sessions_url('user[username]' => 'sas@vito.be', 'user[password]' => 'Biljartisplezant456'), headers: {'Accept' => 'application/json'}
    token_bearer = response.headers['Authorization']

    get api_v1_projects_url(filter: URI.encode_www_form(owner: '', construction_year: 1988, rating: 0, main_scheme: '')), headers: {'Accept' => 'application/json', 'Authorization' => token_bearer}

    puts response.headers
    puts response.body
  end

  test 'should get project' do
    post api_sessions_url('user[username]' => "sas@vito.be", 'user[password]' => "Biljartisplezant456"), headers: {'Accept' => 'application/json'}
    token_bearer = response.headers['Authorization']

    get api_v1_project_url(id: 999), headers: {'Accept' => 'application/json', 'Authorization' => token_bearer}

    puts response.headers
    puts response.body
  end
end
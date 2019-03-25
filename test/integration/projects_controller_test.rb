require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest

  test 'should get project' do
    post api_sessions_url('user[username]' => "sas@vito.be", 'user[password]' => "Biljartisplezant456"), headers: {'Accept' => 'application/json'}
    token_bearer = response.headers['Authorization']

    get api_v1_project_url(id: 216), {}, headers: {'Accept' => 'application/json', 'Authorization' => token_bearer}

    puts response.headers
    puts response.body
  end
end
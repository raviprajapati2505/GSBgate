require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest

  test 'should get projects' do
    post api_sessions_url('user[username]' => 'sas@vito.be', 'user[password]' => 'Biljartisplezant456'), headers: {'Accept' => 'application/json'}
    token_bearer = response.headers['Authorization']

    # get api_v1_projects_url(filter: URI.encode_www_form(typology: 'Premium Scheme', country: 'Qatar')), headers: {'Accept' => 'application/json', 'Authorization' => token_bearer}
    get api_v1_projects_url(filter: URI.encode_www_form(EPL_band: 'B', WPL_band: '-')), headers: {'Accept' => 'application/json', 'Authorization' => token_bearer}

    puts response.headers
    puts response.body
  end

  test 'should get project' do
    post api_sessions_url('user[username]' => "sas@vito.be", 'user[password]' => "Biljartisplezant456"), headers: {'Accept' => 'application/json'}
    token_bearer = response.headers['Authorization']

    get api_v1_project_url(id: 1012), headers: {'Accept' => 'application/json', 'Authorization' => token_bearer}

    puts response.headers
    puts response.body
  end

  test 'should get typologies' do
    post api_sessions_url('user[username]' => 'sas@vito.be', 'user[password]' => 'Biljartisplezant456'), headers: {'Accept' => 'application/json'}
    token_bearer = response.headers['Authorization']

    get api_v1_typologies_url(), headers: {'Accept' => 'application/json', 'Authorization' => token_bearer}

    puts response.headers
    puts response.body
  end
end
ENV['RACK_ENV'] = 'test'

require_relative 'service'

require 'fileutils'
require 'json'

require 'rspec'
require 'rack/test'

describe 'The Contacts Web Service' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    File.delete('db/test.json')
    FileUtils.cp('db/pristine.json', 'db/test.json')
  end

  it "should list all contacts" do
    get '/api/1.0/contacts'
    expect(last_response).to be_ok

    result = JSON.parse(last_response.body)

    expect(result).to be_an_instance_of(Array)
    expect(result.size).to eq(2)
    expect(result[0].size).to eq(2)
    expect(result[0].keys).to include("id")
    expect(result[0].keys).to include("name")
    expect(result[0]["id"]).to eq(0)
    expect(result[0]["name"]).to eq("Roy G. Biv")
  end

  it "should delete a contact" do
    get '/api/1.0/contacts'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result.size).to eq(2)

    delete '/api/1.0/contacts/0'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Hash)
    expect(result.size).to eq(1)
    expect(result["status"]).to eq("Contact 0 deleted")

    get '/api/1.0/contacts'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result.size).to eq(1)
    expect(result[0]["id"]).to eq(1)
  end

  it "should handle GET requests for non-existent contacts" do
    get '/api/1.0/contacts/20'
    expect(last_response.status).to eq(404)
    result = JSON.parse(last_response.body)
    expect(result["error"]).to eq("Contact not found")
  end

end

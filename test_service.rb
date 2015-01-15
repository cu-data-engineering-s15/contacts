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

  def reset_app
    File.delete('db/test.json')
    FileUtils.cp('db/pristine.json', 'db/test.json')
    get '/api/1.0/reset'
  end

  before(:each) do
    reset_app
  end

  after(:all) do
    reset_app
  end

  it "should list all contacts" do
    # get list of contacts
    get '/api/1.0/contacts'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)

    # check that we have two contacts in the right format
    # and with values we expect from our test data
    expect(result).to be_an_instance_of(Array)
    expect(result.size).to eq(2)
    expect(result[0].size).to eq(2)
    expect(result[0].keys).to include("id")
    expect(result[0].keys).to include("name")
    expect(result[0]["id"]).to eq(0)
    expect(result[0]["name"]).to eq("Roy G. Biv")
  end

  it "should create a contact" do
    # verify that we start with two contacts
    get '/api/1.0/contacts'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Array)
    expect(result.size).to eq(2)

    # create a contact
    post '/api/1.0/contacts', {
      :name      => "Shimmer",
      :birthdate => "02/05/1960",
      :email     => "shimmer@crimsonguard.com",
      :phone     => "303-555-5525",
      :twitter   => "@shimmer"}.to_json

    # verify that the new contact is passed back
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Hash)
    expect(result.size).to eq(6)
    expect(result["id"]).to eq(2)
    expect(result["name"]).to eq("Shimmer")

    # verify that we end with three contacts
    get '/api/1.0/contacts'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Array)
    expect(result.size).to eq(3)

  end

  it "should delete a contact" do
    # verify that we start with two contacts
    get '/api/1.0/contacts'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result.size).to eq(2)

    # delete the first contact; check the response
    delete '/api/1.0/contacts/0'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Hash)
    expect(result.size).to eq(2)
    expect(result["status"]).to be true
    expect(result["message"]).to eq("Contact 0 deleted")

    # verify that we end with one contact with an id of "1"
    get '/api/1.0/contacts'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result.size).to eq(1)
    expect(result[0]["id"]).to eq(1)
  end

  it "should handle GET requests for non-existent contacts" do
    # ask for a contact with an id that does not exist
    # verify that a 404 is generated with the appropriate message
    get '/api/1.0/contacts/20'
    expect(last_response.status).to eq(404)
    result = JSON.parse(last_response.body)
    expect(result["error"]).to eq("Contact not found")
  end

  it "should get a contact" do
    get '/api/1.0/contacts/0'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Hash)
    expect(result.size).to eq(6)
    expect(result["id"]).to eq(0)
    expect(result["name"]).to eq("Roy G. Biv")
    expect(result["birthdate"]).to eq("01/01/1901")
    expect(result["email"]).to eq("roy.g.biv@biv.com")
    expect(result["phone"]).to eq("+1 303-555-5500")
    expect(result["twitter"]).to eq("@rainbow")
  end

  it "should update a contact" do
    put '/api/1.0/contacts/0', {
      :expected => {
        :name      => "Roy G. Biv",
        :birthdate => "01/01/1901",
        :email     => "roy.g.biv@biv.com",
        :phone     => "+1 303-555-5500",
        :twitter   => "@rainbow"
      },
      :updated => {
        :name      => "Roy Green Biv",
        :birthdate => "01/01/2001",
        :email     => "roy@gbiv.com",
        :phone     => "+1 303-555-5555",
        :twitter   => "@roygbiv"}
      }.to_json
    expect(last_response).to be_ok

    get '/api/1.0/contacts/0'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Hash)
    expect(result.size).to eq(6)
    expect(result["id"]).to eq(0)
    expect(result["name"]).to eq("Roy Green Biv")
    expect(result["birthdate"]).to eq("01/01/2001")
    expect(result["email"]).to eq("roy@gbiv.com")
    expect(result["phone"]).to eq("+1 303-555-5555")
    expect(result["twitter"]).to eq("@roygbiv")

  end

  it "can search contacts for a single match" do
    get '/api/1.0/search?q=Roy'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Array)
    expect(result.size).to eq(1)
    expect(result[0]["name"]).to eq("Roy G. Biv")
  end

  it "can search contacts for multiple matches" do
    get '/api/1.0/search?q=555'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Array)
    expect(result.size).to eq(2)
    expect(result[0]["name"]).to eq("Roy G. Biv")
    expect(result[1]["name"]).to eq("Luke Skywalker")
  end

  it "can search contacts for no match" do
    get '/api/1.0/search?q=Zanzibar'
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Hash)
    expect(result.size).to eq(2)
    expect(result["status"]).to be false
  end

  it "can search for upcoming birthdays and find them" do
    post '/api/1.0/upcomingbirthdays', { :date => "12/01/2014"}.to_json
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Array)
    expect(result.size).to eq(2)
  end

  it "can search for upcoming birthdays and not find them" do
    post '/api/1.0/upcomingbirthdays', { :date => "06/01/2014"}.to_json
    expect(last_response).to be_ok
    result = JSON.parse(last_response.body)
    expect(result).to be_an_instance_of(Hash)
    expect(result.size).to eq(2)
    expect(result["status"]).to be false
  end

end

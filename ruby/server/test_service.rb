ENV['RACK_ENV'] = 'test'

require_relative 'service'

require 'fileutils'
require 'json'

require 'rspec'
require 'rack/test'

describe 'The Contacts Web Service' do
  include Rack::Test::Methods

  # test helper methods
  def reset_app
    File.delete('db/test.json')
    FileUtils.cp('db/pristine.json', 'db/test.json')
    get '/api/1.0/reset'
  end

  def process_response
    expect(last_response).to be_ok
    return JSON.parse(last_response.body)
  end

  def verify_success(response)
    expect(response).to be_an_instance_of(Hash)
    expect(response.keys).to match_array(["status", "data"])
    expect(response['status']).to be true
    expect(response['data']).to be_truthy
    return response['data']
  end

  def verify_failure(response)
    expect(response).to be_an_instance_of(Hash)
    expect(response.keys).to match_array(["status", "error"])
    expect(response['status']).to be false
    expect(response['error']).to be_truthy
    return response['error']
  end

  def verify_contacts(list)
    expect(list).to be_an_instance_of(Array)
    yield list
  end

  def verify_contact(contact)
    keys = ["id", "name", "birthdate", "email", "phone", "twitter"]
    expect(contact).to be_an_instance_of(Hash)
    expect(contact.size).to eq(6)
    expect(contact.keys).to match_array(keys)
    yield contact
  end

  def app
    ContactsService
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

    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(2)

      item = list[0]

      expect(item.keys).to match_array(["id", "name"])
      expect(item["id"]).to eq(0)
      expect(item["name"]).to eq("Roy G. Biv")
    
    end

  end

  it "should create a contact" do
    # verify that we start with two contacts
    get '/api/1.0/contacts'
    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(2)
    end

    # create a contact
    post '/api/1.0/contacts', {
      :name      => "Shimmer",
      :birthdate => "02/05/1960",
      :email     => "shimmer@crimsonguard.com",
      :phone     => "303-555-5525",
      :twitter   => "@shimmer"}.to_json

    # verify that the new contact is passed back
    verify_contact(verify_success(process_response)) do |contact|
      expect(contact["id"]).to eq(2)
      expect(contact["name"]).to eq("Shimmer")
    end

    # verify that we end with three contacts
    get '/api/1.0/contacts'
    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(3)
    end

  end

  it "should delete a contact" do
    # verify that we end with two contacts
    get '/api/1.0/contacts'
    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(2)
    end

    # delete the first contact; check the response
    delete '/api/1.0/contacts/0'

    verify_success(process_response)

    # verify that we end with one contact with an id of 1"
    get '/api/1.0/contacts'
    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(1)
      expect(list[0]["id"]).to eq(1)
    end

  end

  it "should handle GET requests for non-existent contacts" do
    get '/api/1.0/contacts/20'
    message = verify_failure(process_response)
    expect(message).to eq("Contact 20 not found")
  end

  it "should get a contact" do
    get '/api/1.0/contacts/0'

    verify_contact(verify_success(process_response)) do |contact|
      expect(contact["id"]).to eq(0)
      expect(contact["name"]).to eq("Roy G. Biv")
      expect(contact["birthdate"]).to eq("01/01/1901")
      expect(contact["email"]).to eq("roy.g.biv@biv.com")
      expect(contact["phone"]).to eq("+1 303-555-5500")
      expect(contact["twitter"]).to eq("@rainbow")
    end
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

    verify_success(process_response)

    get '/api/1.0/contacts/0'
    verify_contact(verify_success(process_response)) do |contact|
      expect(contact["id"]).to eq(0)
      expect(contact["name"]).to eq("Roy Green Biv")
      expect(contact["birthdate"]).to eq("01/01/2001")
      expect(contact["email"]).to eq("roy@gbiv.com")
      expect(contact["phone"]).to eq("+1 303-555-5555")
      expect(contact["twitter"]).to eq("@roygbiv")
    end

  end

  it "can search contacts for a single match" do
    get '/api/1.0/search?q=Roy'
    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(1)
      verify_contact(list[0]) do |contact|
        expect(contact["name"]).to eq("Roy G. Biv")
      end
    end
  end

  it "can search contacts for multiple matches" do
    get '/api/1.0/search?q=555'
    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(2)
      verify_contact(list[0]) do |contact|
        expect(contact["name"]).to eq("Roy G. Biv")
      end
      verify_contact(list[1]) do |contact|
        expect(contact["name"]).to eq("Luke Skywalker")
      end
    end
  end

  it "can search contacts for no match" do
    get '/api/1.0/search?q=Zanzibar'
    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(0)
    end
  end

  it "can search for upcoming birthdays and find them" do
    post '/api/1.0/upcomingbirthdays', { date: "12/01/2014"}.to_json
    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(2)
    end
  end

  it "can search for upcoming birthdays and not find them" do
    post '/api/1.0/upcomingbirthdays', { date: "06/01/2014"}.to_json
    verify_contacts(verify_success(process_response)) do |list|
      expect(list.size).to eq(0)
    end
  end

end

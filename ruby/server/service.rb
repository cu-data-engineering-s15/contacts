require 'sinatra/base'

require 'json'
require 'fileutils'

require_relative '../model/contact'

class ContactsService < Sinatra::Base

  def initialize
    super
    load_contacts
  end

  def load_contacts

    f    = File.open(settings.db)
    data = f.read.chomp
    f.close
    data = JSON.parse(data, :create_additions => true)

    db = data["db"]

    settings.contacts.clear

    db.keys.each {|key| settings.contacts[key.to_i] = db[key] }

    settings.next_id = data["next_id"]

  end

  def save_contacts
    data = {"db" => settings.contacts, "next_id" => settings.next_id}
    f = File.open(settings.db, 'w')
    f.puts data.to_json
    f.close
  end

  def create_contact_from_data(from_request, id)
    data = {}
    from_request.keys.each {|key| data[key.to_sym] = from_request[key] }
    data[:id] = id
    data[:birthdate] = Date.strptime(data[:birthdate], '%m/%d/%Y')
    Contact.new(data)
  end

  def add_new_contact(contact)
    settings.contacts[contact.id] = contact
    settings.next_id += 1
    save_contacts
  end

  configure do
    enable :method_override
    enable :logging
    set :db, "db/contacts.json"
    set :contacts, {}
    set :next_id, 0
  end

  configure :test do
    set :db, "db/test.json"
    set :pristine, "db/pristine.json"
  end

  get '/api/1.0/reset' do
    if settings.test?
      File.delete(settings.db)
      FileUtils.cp(settings.pristine, settings.db)
      load_contacts
      content_type :json
      { status: true, data: [] }.to_json
    end
  end

  get '/api/1.0/shutdown' do
    if settings.test?
      exit!
    end
  end

  get '/api/1.0/contacts' do
    items = settings.contacts.values.map { |c| c.summary_response }
    content_type :json
    {status: true, data: items}.to_json
  end

  post '/api/1.0/contacts' do
    data        = JSON.parse(request.body.read)

    new_contact = create_contact_from_data(data, settings.next_id)

    add_new_contact(new_contact)

    content_type :json
    {status: true, data: new_contact.full_response}.to_json
  end

  get '/api/1.0/contacts/:id' do
    id = params[:id].to_i
    content_type :json
    if settings.contacts.has_key?(id)
      {status: true, data: settings.contacts[id].full_response}.to_json
    else
      {status: false, error: "Contact #{id} not found"}.to_json
    end
  end

  put '/api/1.0/contacts/:id' do
    id       = params[:id].to_i
    data     = JSON.parse(request.body.read)
    expected = create_contact_from_data(data['expected'], id)
    updated  = create_contact_from_data(data['updated'], id)
    current  = settings.contacts[id]

    content_type :json
    if current == expected
      settings.contacts[id] = updated
      save_contacts
      {status: true, data: updated.full_response}.to_json
    else
      {status: false, error: "Expected information was stale."}.to_json
    end
  end

  delete '/api/1.0/contacts/:id' do
    id = params[:id].to_i
    content_type :json
    if settings.contacts.has_key?(id)
      settings.contacts.delete(id)
      save_contacts
      { status: true, data: [] }.to_json
    else
      {status: false, error: "Contact #{id} not found"}.to_json
    end
  end

  get '/api/1.0/search' do
    items = settings.contacts.values.select {|c| c.contains?(params['q']) }
    items = items.map { |c| c.full_response }
    content_type :json
    {status: true, data: items}.to_json
  end

  get '/api/1.0/upcomingbirthdays' do
    matches = settings.contacts.values.select {|c| c.upcoming_birthday? }
    matches = matches.map { |c| c.full_response }
    content_type :json
    {status: true, data: matches}.to_json
  end

  post '/api/1.0/upcomingbirthdays' do
    data = JSON.parse(request.body.read)
    date = Date.strptime(data["date"], '%m/%d/%Y')
    items = settings.contacts.values.select {|c| c.upcoming_birthday?(date)}
    items = items .map { |c| c.full_response }
    content_type :json
    {status: true, data: items }.to_json
  end

end

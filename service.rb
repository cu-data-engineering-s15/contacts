require 'json'
require 'sinatra'
require 'sinatra/reloader' if development?

require_relative 'contact'

$contacts = nil
$next_id  = 0

def load_contacts
  f    = File.open(settings.db)
  data = f.read.chomp
  f.close
  data = JSON.parse(data, :create_additions => true)

  tmp = data["db"]
  $contacts = {}
  tmp.keys.each {|key| $contacts[key.to_i] = tmp[key] }
  $next_id  = data["next_id"]
end

def save_contacts
  data = {"db" => $contacts, "next_id" => $next_id}
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
  $contacts[contact.id] = contact
  $next_id += 1
  save_contacts
end

configure do
  set :port, 3000
  set :db, "db/contacts.json"
  load_contacts
end

configure :test do
  set :db, "db/test.json"
end

get '/api/1.0/reset' do
  if settings.test?
    load_contacts
    { status: true, data: [] }.to_json
  end
end

get '/api/1.0/contacts' do
  contacts = $contacts.values.map { |c| c.summary_response }
  {status: true, data: contacts}.to_json
end

post '/api/1.0/contacts' do
  data        = JSON.parse(request.body.read)

  new_contact = create_contact_from_data(data, $next_id)

  add_new_contact(new_contact)

  {status: true, data: new_contact.full_response}.to_json
end

get '/api/1.0/contacts/:id' do
  id = params[:id].to_i
  if $contacts.has_key?(id)
    {status: true, data: $contacts[id].full_response}.to_json
  else
    {status: false, error: "Contact #{id} not found"}.to_json
  end
end

put '/api/1.0/contacts/:id' do
  id       = params[:id].to_i
  data     = JSON.parse(request.body.read)
  expected = create_contact_from_data(data['expected'], id)
  updated  = create_contact_from_data(data['updated'], id)
  current  = $contacts[id]

  if current == expected
    $contacts[id] = updated
    save_contacts
    {status: true, data: updated.full_response}.to_json
  else
    {status: false, error: "Expected information was stale."}.to_json
  end
end

delete '/api/1.0/contacts/:id' do
  id = params[:id].to_i
  if $contacts.has_key?(id)
    $contacts.delete(id)
    save_contacts
    { status: true, data: [] }.to_json
  else
    {status: false, error: "Contact #{id} not found"}.to_json
  end
end

get '/api/1.0/search' do
  matches = $contacts.values.select {|c| c.contains?(params['q']) }
  matches = matches.map { |c| c.full_response }
  {status: true, data: matches}.to_json
end

get '/api/1.0/upcomingbirthdays' do
  matches = $contacts.values.select {|c| c.upcoming_birthday? }
  matches = matches.map { |c| c.full_response }
  {status: true, data: matches}.to_json
end

post '/api/1.0/upcomingbirthdays' do
  data = JSON.parse(request.body.read)
  date = Date.strptime(data["date"], '%m/%d/%Y')
  matches = $contacts.values.select {|c| c.upcoming_birthday?(date) }
  matches = matches.map { |c| c.full_response }
  {status: true, data: matches}.to_json
end

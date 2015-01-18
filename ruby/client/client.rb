require 'typhoeus'
require 'json'

require_relative 'contact'

def base_uri
  "http://localhost:3000"
end

def available_contacts
  url      = "#{base_uri}/api/1.0/contacts"
  response = Typhoeus.get(url)
  if response.code == 200
    result = JSON.parse(response.body)
    result.map {|entry| entry["name"] }
  else
    raise response.body
  end
end

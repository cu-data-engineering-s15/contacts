require 'typhoeus'
require 'json'

require_relative '../model/contact'

class NotConnected < StandardError
end

class ServiceError < StandardError
end

class Contacts

  def base_uri
    "http://localhost:3000"
  end

  def available_contacts
    url      = "#{base_uri}/api/1.0/contacts"
    response = Typhoeus.get(url)
    raise NotConnected if response.code == 0
    if response.code == 200
      result = JSON.parse(response.body)
      raise ServiceError if !result["status"]
      return result["data"]
    end
    raise ServiceError
  end

end

require 'typhoeus'
require 'json'

require '../model/contact'

require_relative '../model/contact'

class NotConnected < StandardError
end

class ServiceError < StandardError
end

class Contacts

  def create_contact_from_data(from_response)
    data = {}
    from_response.keys.each {|key| data[key.to_sym] = from_response[key] }
    data[:birthdate] = Date.strptime(data[:birthdate], '%m/%d/%Y')
    Contact.new(data)
  end

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

  def create(data)
    url      = "#{base_uri}/api/1.0/contacts"
    response = Typhoeus.post(url, body: data.to_json)
    raise NotConnected if response.code == 0
    if response.code == 200
      result = JSON.parse(response.body)
      raise ServiceError if !result["status"]
      return create_contact_from_data(result['data'])
    end
    raise ServiceError
  end

  def reset
    url      = "#{base_uri}/api/1.0/reset"
    response = Typhoeus.get(url)
    raise NotConnected if response.code == 0
    if response.code == 200
      result = JSON.parse(response.body)
      raise ServiceError if !result["status"]
    end
  end

end

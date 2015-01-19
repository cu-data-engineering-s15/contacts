require 'typhoeus'
require 'json'

require '../model/contact'

require_relative '../model/contact'

class NotConnected < StandardError
end

class FailureResult < StandardError
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

  def handle_request(method, uri, data = nil)
    url      = "#{base_uri}/#{uri}"
    info     = { "Content-Type" => "application/json" }
    params   = {method: method, body: data, headers: info }
    request  = Typhoeus::Request.new(url, params)
    request.run
    response = request.response

    raise NotConnected if response.code == 0
    if response.code == 200
      result = JSON.parse(response.body)
      #puts result.inspect
      if result["status"]
        yield result["data"]
      else
        raise FailureResult.new(result["error"])
      end
    end
    raise ServiceError
  end

  def available_contacts
    handle_request(:get, "api/1.0/contacts") do |list|
      return list
    end
  end

  def create(data)
    handle_request(:post, "api/1.0/contacts", data.to_json) do |atts|
      return create_contact_from_data(atts)
    end
  end

  def delete(id)
    handle_request(:delete, "api/1.0/contacts/#{id}") do |ignore|
      return true
    end
  end

  def get(id)
    handle_request(:get, "api/1.0/contacts/#{id}") do |atts|
      return create_contact_from_data(atts)
    end
  end

  def update(id, contact, data)
    data = {
      expected: {
        name: contact.name,
        birthdate: contact.birthdate.strftime('%m/%d/%Y'),
        email: contact.email,
        phone: contact.phone,
        twitter: contact.twitter
      },
      updated: data
    }
    handle_request(:put, "api/1.0/contacts/#{id}", data.to_json) do |ignore|
      return
    end
  end

  def search(query)
    handle_request(:get, "api/1.0/search?q=#{query}") do |list|
      return list.map { |atts| create_contact_from_data(atts) }
    end
  end

  def upcomingbirthdays(date = nil)
    if date.nil?
      handle_request(:get, "api/1.0/upcomingbirthdays") do |list|
        return list.map { |atts| create_contact_from_data(atts) }
      end
    else
      data = { date: date }
      handle_request(:post,
                     "api/1.0/upcomingbirthdays",
                     data.to_json) do |list|
        return list.map { |atts| create_contact_from_data(atts) }
      end
    end
  end

  def reset
    handle_request(:get, "api/1.0/reset") do |ignore|
      return
    end
  end

end

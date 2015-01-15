require 'json'
require 'time'

class Contact

  attr_reader :id, :name, :birthdate, :email, :phone, :twitter

  def initialize(params)
    @id        = params[:id]
    @name      = params[:name]
    @birthdate = params[:birthdate]
    @email     = params[:email]
    @phone     = params[:phone]
    @twitter   = params[:twitter]
  end

  def ==(contact)
    return false if self.id != contact.id
    return false if self.name != contact.name
    return false if self.birthdate != contact.birthdate
    return false if self.email != contact.email
    return false if self.phone != contact.phone
    return false if self.twitter != contact.twitter
    true
  end

  def contains(query)
    query = query.downcase
    return true if self.name.downcase.include?(query)
    return true if self.email.downcase.include?(query)
    return true if self.phone.downcase.include?(query)
    return true if self.twitter.downcase.include?(query)

    birthdate_str = self.birthdate.strftime('%m/%d/%Y')

    return birthdate_str.include?(query)

  end

  def summary_response
    {
      "id" => @id,
      "name" => @name
    }
  end

  def full_response
    {
      "id"        => @id,
      "name"      => @name,
      "birthdate" => @birthdate.strftime('%m/%d/%Y'),
      "email"     => @email,
      "phone"     => @phone,
      "twitter"   => @twitter
    }
  end

  def to_json(*a)
    { "json_class" => self.class.name,
      "data" =>
        {"id"        => @id,
         "name"      => @name,
         "birthdate" => @birthdate.strftime('%m/%d/%Y'),
         "email"     => @email,
         "phone"     => @phone,
         "twitter"   => @twitter }
    }.to_json(*a)
  end

  def self.json_create(o)
    data = {}
    data[:id]        = o["data"]["id"]
    data[:name]      = o["data"]["name"]
    data[:birthdate] = Date.strptime(o["data"]["birthdate"], '%m/%d/%Y')
    data[:email]     = o["data"]["email"]
    data[:phone]     = o["data"]["phone"]
    data[:twitter]   = o["data"]["twitter"]
    new(data)
  end

end

require_relative 'contact'

describe 'The Contact Model' do

  before(:each) do
    @data_roy  = {}

    @data_roy[:id]        = 0
    @data_roy[:name]      = "Roy G. Biv"
    @data_roy[:birthdate] = Date.strptime('01/01/1901', '%m/%d/%Y')
    @data_roy[:email]     = "roy.g.biv@biv.com"
    @data_roy[:phone]     = "+1 303-555-5500"
    @data_roy[:twitter]   = "@rainbow"

    @data_luke = {}

    @data_luke[:id]        = 1
    @data_luke[:name]      = "Luke Skywalker"
    @data_luke[:birthdate] = Date.strptime('02/02/2001', '%m/%d/%Y')
    @data_luke[:email]     = "luke@skywalker.org"
    @data_luke[:phone]     = "+1 303-555-5501"
    @data_luke[:twitter]   = "@jedi"
  end

  it "can create a new contact" do
    roy = Contact.new(@data_roy)
    expect(roy).to be_an_instance_of(Contact)
    expect(roy.id).to eq(0)
    expect(roy.name).to eq("Roy G. Biv")
    expect(roy.birthdate).to be_an_instance_of(Date)
    expect(roy.birthdate.month).to eq(1)
    expect(roy.email).to eq("roy.g.biv@biv.com")
    expect(roy.phone).to eq("+1 303-555-5500")
    expect(roy.twitter).to eq("@rainbow")
  end

  it "can determine that two contacts with the same data are equal" do
    roy_1 = Contact.new(@data_roy)
    roy_2 = Contact.new(@data_roy)
    expect(roy_1 == roy_2).to be true
  end

  it "can determine that two contacts with different data are not equal" do
    roy  = Contact.new(@data_roy)
    luke = Contact.new(@data_luke)
    expect(roy == luke).to be false
  end

  it "can search a contact's attributes and find a match" do
    roy  = Contact.new(@data_roy)
    expect(roy.contains?('oy')).to be true
    expect(roy.contains?('303')).to be true
    expect(roy.contains?('RAIN')).to be true
    expect(roy.contains?('1901')).to be true
  end

  it "can search a contact's attributes and not find a match" do
    roy  = Contact.new(@data_roy)
    expect(roy.contains?('luke')).to be false
    expect(roy.contains?('JEDI')).to be false
  end

  it "can convert a Contact to JSON and back to the same Contact" do
    roy        = Contact.new(@data_roy)
    roy_string = roy.to_json
    roy_2      = JSON.parse(roy_string, :create_additions => true)
    expect(roy == roy_2).to be true
  end

  it "can detect that its birthday is near" do
    roy   = Contact.new(@data_roy)
    luke  = Contact.new(@data_luke)
    today = Date.strptime('12/01/2003', '%m/%d/%Y')
    expect(roy.upcoming_birthday?(today)).to be true
    expect(luke.upcoming_birthday?(today)).to be true
  end

  it "can detect that its birthday is not near" do
    roy   = Contact.new(@data_roy)
    luke  = Contact.new(@data_luke)
    today = Date.strptime('06/01/2014', '%m/%d/%Y')
    expect(roy.upcoming_birthday?(today)).to be false
    expect(luke.upcoming_birthday?(today)).to be false
  end

end

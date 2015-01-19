require_relative 'client'

require_relative '../model/contact'

describe 'The Contacts Client API' do

  before(:each) do
    @contacts = Contacts.new
  end

  after(:each) do
    @contacts = Contacts.new
    @contacts.reset
  end

  it "should list available contacts" do
    list = @contacts.available_contacts
    expect(list).to be_an_instance_of(Array)
    expect(list[0]["name"]).to eq("Roy G. Biv")
  end

  it "should create a new contact" do
    list = @contacts.available_contacts
    expect(list.size).to eq(2)

    data = {
      "name"      => "Ken Anderson",
      "birthdate" => "06/10/1905",
      "email"     => "ken.anderson@colorado.edu",
      "phone"     => "+1 303-492-6003",
      "twitter"   => "@kenbod"
    }

    c = @contacts.create(data)

    expect(c).to be_an_instance_of(Contact)
    expect(c.name).to eq("Ken Anderson")

    list = @contacts.available_contacts
    expect(list.size).to eq(3)
  end

  it "should delete a contact" do
  end

  it "should return nil for non-existent contacts" do
  end

  it "should get a contact" do
  end

  it "should update a contact" do
  end

  it "should find a contact" do
  end

  it "should list upcoming birthdays" do
  end

end

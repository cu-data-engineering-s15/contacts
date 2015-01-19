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
    expect(list[0]["id"]).to eq(0)
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
    list = @contacts.available_contacts
    expect(list.size).to eq(2)

    @contacts.delete(0)

    list = @contacts.available_contacts
    expect(list.size).to eq(1)
  end

  it "should raise a failure result when deleting non-existent contact" do
    expect { @contacts.delete(20) }.to raise_error(FailureResult)
  end

  it "should get a contact" do
    c = @contacts.get(0)

    expect(c).to be_an_instance_of(Contact)
    expect(c.name).to eq("Roy G. Biv")
  end

  it "should raise a failure result when getting non-existent contact" do
    expect { @contacts.get(20) }.to raise_error(FailureResult)
  end

  it "should update a contact" do
    c = @contacts.get(0)

    data = {
      "name"      => "Roy Green Biv",
      "birthdate" => "01/01/2001",
      "email"     => "roy@gbiv.com",
      "phone"     => "+1 303-555-5555",
      "twitter"   => "@roygbiv"
    }

    @contacts.update(0, c, data)

    c = @contacts.get(0)

    expect(c).to be_an_instance_of(Contact)
    expect(c.name).to eq("Roy Green Biv")
    expect(c.twitter).to eq("@roygbiv")
  end

  it "should find a contact" do
    list = @contacts.search("Roy")
    expect(list).to be_an_instance_of(Array)
    expect(list.size).to eq(1)
    expect(list[0]).to be_an_instance_of(Contact)
    expect(list[0].name).to eq("Roy G. Biv")
  end

  it "should find upcoming birthdays" do
    list = @contacts.upcomingbirthdays("12/01/2014")
    expect(list).to be_an_instance_of(Array)
    expect(list.size).to eq(2)
    expect(list[0]).to be_an_instance_of(Contact)
    expect(list[0].name).to eq("Roy G. Biv")
  end

  it "can't find upcoming birthdays" do
    list = @contacts.upcomingbirthdays("06/01/2014")
    expect(list).to be_an_instance_of(Array)
    expect(list.size).to eq(0)
  end

end

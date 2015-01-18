require_relative 'client'

describe 'The Contacts Client API' do

  before(:each) do
    @contacts = Contacts.new
  end

  it "should list available contacts" do
    list = @contacts.available_contacts
    expect(list).to be_an_instance_of(Array)
    expect(list[0]["name"]).to eq("Roy G. Biv")
  end

end

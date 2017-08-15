require 'spec_helper'

RSpec.describe DB do

  it 'has a key conn that is an instance of SQLite' do
    expect(DB[:conn]).to be_a(SQLite3::Database)
  end

end
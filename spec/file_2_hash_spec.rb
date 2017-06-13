require 'spec_helper'

describe Marta::SmartPage do
  before(:all) do
    @full_name = "./spec/test_data_folder/test_pageobjects/Json2Class.json"
    @bad_name = "./spec/test_data_folder/test_pageobjects/Bad.json"
    @fake_name = "./spec/test_data_folder/test_pageobjects/Fake.json"
  end

  it 'will return nil instead of hash on parsing error' do
    expect(marta_fire(:file_2_hash, @bad_name)).to eq nil
  end

  it 'will return nil instead of hash if json file does not exist' do
    expect(marta_fire(:file_2_hash, @fake_name)).to eq nil
  end

  it 'will return a Hash for given json' do
    expect(marta_fire(:file_2_hash, @full_name).class).to eq Hash
  end
end

require 'spec_helper'

describe Marta::SmartPage do
  before(:all) do
    @name = 'File_write_test'
    @full_name = "./spec/test_data_folder/test_pageobjects/#{@name}.json"
    @data = {"vars": {"a": "B"},"meths":{}}
    FileUtils.rm_rf(@full_name)#To be sure that we have no precreated file
  end

  #it 'can create folder if it does not exist' do
    #We can not check it unless we can not switch @@dir dynamically
  #end

  it 'can create json file' do
    expect(File.exists?(marta_fire(:file_write, @name, @data))).to be true
  end

  it 'and the file should include correct info' do
    file = File.read(@full_name)
    data_hash = JSON.parse(file)
    expect(data_hash["vars"]["a"]).to eq("B")
  end

  after(:all) do
    FileUtils.rm_rf(@full_name)
  end
end

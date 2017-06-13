require 'spec_helper'

describe Marta::SmartPage, :need_browser do

  before(:all) do
    @name = 'Dialogs'
    @full_name = "./spec/test_data_folder/test_pageobjects/#{@name}.json"
    @page_3_name = "./spec/test_data_folder/test_pageobjects/Page_three.json"
    @data, @data['meths'], @data['vars'] = Hash.new, Hash.new, Hash.new
    @page_one_url = "file://#{Dir.pwd}" + "/spec/test_data_folder/page_one.html"
    @page_two_url = "file://#{Dir.pwd}" + "/spec/test_data_folder/page_two.html"
    @page_three_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_three.html"
    FileUtils.rm_rf(@full_name)#To be sure that we have no precreated file
  end

  it 'can perform basic element selection user story' do
    @browser.goto @page_one_url
    marta_fire(:user_method_dialogs, "Dialogs", "hello_world", @data)
    expect(File.exists?(@full_name)).to be true
    file = File.read(@full_name)
    data_hash = JSON.parse(file)
    expect(data_hash["meths"]["hello_world"]["self"]["class"].length).to eq(3)
    expect(data_hash["meths"]["hello_world"]["self"]["id"]).to eq("element1")
  end

  it "can save element by xpath" do
    @browser.goto @page_two_url
    marta_fire(:user_method_dialogs, "Dialogs", "hello_world", @data)
    expect(File.exists?(@full_name)).to be true
    file = File.read(@full_name)
    data_hash = JSON.parse(file)
    expect(data_hash['meths']['hello_world']['options']['xpath']).to eq('//Fancy/xpath')
  end

  it 'finds predefined element' do
    page_3 = Page_three.new
    @browser.goto @page_three_url
    marta_fire(:user_method_dialogs, "Page_three",
      "hello_world", JSON.parse(File.read(@page_3_name)))
    expect(File.exists?(@page_3_name)).to be true
    file = File.read(@page_3_name)
    data_hash = JSON.parse(file)
    expect(data_hash["meths"]["hello_world"]["self"]["class"].length).to eq(3)
    expect(data_hash["meths"]["hello_world"]["self"]["id"]).to eq("element1")
  end

  it 'treats a collection mark' do
  end

  after(:each) do
    FileUtils.rm_rf(@full_name)
  end
end

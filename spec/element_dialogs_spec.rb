require 'spec_helper'
require 'pry'

describe Marta::SmartPage, :need_browser do

  # Theese tests are slightly not stable for some reason! Careful!

  before(:all) do
    @name = 'Dialogs'
    @full_name = "./spec/test_data_folder/test_pageobjects/#{@name}.json"
    @page_3_name = "./spec/test_data_folder/test_pageobjects/Page_three.json"
    @data, @data['meths'], @data['vars'] = Hash.new, Hash.new, Hash.new
    @page_one_url = "file://#{Dir.pwd}" + "/spec/test_data_folder/page_one.html"
    @page_two_url = "file://#{Dir.pwd}" + "/spec/test_data_folder/page_two.html"
    @page_three_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_three.html"
    @page_seven_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_seven.html"
    @page_nine_url = "file://#{Dir.pwd}/spec/test_data_folder/page_nine.html"
    FileUtils.rm_rf(@full_name)#To be sure that we have no precreated file
  end

  before(:each) do
    @browser = dance_with learn: true
  end

  it 'can perform basic element selection user story' do
    @browser.goto @page_one_url
    page = Marta::SmartPage.new(@name, ({"vars" => {},"meths" => {}}), false)
    page.send(:user_method_dialogs, "hello_world")
    expect(File.exists?(@full_name)).to be true
    file = File.read(@full_name)
    data_hash = JSON.parse(file)
    expect(data_hash["meths"]["hello_world"]["self"]["class"].length).to eq(3)
    expect(data_hash["meths"]["hello_world"]["self"]["id"]).to eq("element1")
  end

  it "can save element by xpath" do
    @browser.goto @page_two_url
    page = Marta::SmartPage.new(@name, ({"vars" => {},"meths" => {}}), false)
    page.send(:user_method_dialogs, "hello_world")
    expect(File.exists?(@full_name)).to be true
    file = File.read(@full_name)
    data_hash = JSON.parse(file)
    expect(data_hash['meths']['hello_world']['options']['xpath']).to eq('//Fancy/xpath')
  end

  it 'finds predefined element' do
    dance_with learn: false
    page_3 = Page_three.new
    @browser.goto @page_three_url
    page = Marta::SmartPage.new("Page_three",
                                JSON.parse(File.read(@page_3_name)), false)
    dance_with learn: true
    page.send(:user_method_dialogs, "hello_world")
    expect(File.exists?(@page_3_name)).to be true
    file = File.read(@page_3_name)
    data_hash = JSON.parse(file)
    expect(data_hash["meths"]["hello_world"]["self"]["class"].length).to eq(3)
    expect(data_hash["meths"]["hello_world"]["self"]["id"]).to eq("element1")
  end

  it 'can find invisible elements by html' do
    @browser.goto @page_seven_url
    page = Marta::SmartPage.new(@name, ({"vars" => {},"meths" => {}}), false)
    page.send(:user_method_dialogs, "invisible")
    expect(File.exists?(@full_name)).to be true
    file = File.read(@full_name)
    data_hash = JSON.parse(file)
    expect(data_hash["meths"]["invisible"]["self"]["class"][0]).to eq("found")
  end

  it 'treats a collection mark' do
    @browser.goto @page_nine_url
    page = Marta::SmartPage.new(@name, ({"vars" => {},"meths" => {}}), false)
    page.send(:user_method_dialogs, "collection")
    expect(File.exists?(@full_name)).to be true
    file = File.read(@full_name)
    the_collection = JSON.parse(file)["meths"]["collection"]
    expect(the_collection["self"]["class"][0]).to eq("element")
    expect(the_collection["options"]["self"]).to eq("*")
    expect(the_collection["options"]["not_self"]).to eq("LABEL")
    expect(the_collection["not_self"]["class"][0]).to eq("exclude")
    expect(the_collection["not_self"]["retrieved_by_marta_text"]).to eq("Yes!")
  end

  it 'applying dynamic values to attributes' do
    @browser.goto @page_one_url
    page = Marta::SmartPage.new(@name, ({"vars" => {"potato" => "el"},"meths" => {}}), false)
    page.send(:user_method_dialogs, "hello_world")
    expect(File.exists?(@full_name)).to be true
    file = File.read(@full_name)
    data_hash = JSON.parse(file)
    expect(data_hash["meths"]["hello_world"]["self"]["class"][0]).
                                                    to eq("\#{@potato}ement")
    expect(data_hash["meths"]["hello_world"]["self"]["id"]).
                                                    to eq("\#{@potato}ement1")
  end

  after(:each) do
    FileUtils.rm_rf(@full_name)
  end
end

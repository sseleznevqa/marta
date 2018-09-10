require 'spec_helper'

describe Marta::SmartPage, :need_browser do

  before(:all) do
    @name = 'Page'
    @full_name = "./spec/test_data_folder/test_pageobjects/#{@name}.json"
    @data, @data['meths'], @data['vars'] = Hash.new, Hash.new, Hash.new
    @page_four_url = "file://#{Dir.pwd}/spec/test_data_folder/page_four.html"
    @page_eight_url = "file://#{Dir.pwd}/spec/test_data_folder/page_eight.html"
    FileUtils.rm_rf(@full_name)#To be sure that we have no precreated file
  end

  before(:each) do
    dance_with learn: true
    #sleep 5
    #dance_with learn: false
  end

  it 'can perform basic page creation user story' do
    @browser.goto @page_four_url
    Page.new
    expect(File.exists?(@full_name)).to be true
    file = File.read(@full_name)
    data_hash = JSON.parse(file)
    expect(data_hash["vars"]["hello"]).to eq "world"
    dance_with learn: false
    expect(Page.new.hello).to eq "world"
  end

  it 'can edit page variables on fly' do
    @browser.goto @page_eight_url
    page = Page.new
    expect(page.hello).to eq "kitty"
  end

  after(:all) do
    FileUtils.rm_rf(@full_name)
  end
end

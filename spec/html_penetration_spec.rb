require 'spec_helper'
require 'marta/injector'

describe Marta::SmartPage, :need_browser do

  before(:all) do
    @page_three_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_three.html"
    @text1 = "penetrated\nHello World!\nReally, dude."
    @text2 = "Hello World!\nReally, dude. penetrated"
  end

  before(:each) do
    @browser.goto @page_three_url
    @class = Marta::Injector::Syringe.new(@browser, "1", "2", "3", "4")
  end

  it 'insert something to the begining of the page' do
    @class.insert_to_page("span", "penetrated")
    expect(@browser.text).to eq @text1
  end

  it 'insert something to the bottom of the page' do
    @class.insert_to_page("span", "penetrated", false)
    expect(@browser.text).to eq @text2
  end
end

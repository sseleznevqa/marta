require 'spec_helper'

describe Marta::SmartPage do
  it 'can open pages by url', :need_browser do
    marta_fire(:open_page, "about:blank")
    expect(@browser.url).to eq "about:blank"
  end

  it 'cannot open pages without any url' do
    message = "You should set url to use open_page. You may"\
    " also use base_url option for dance_with and path for page object"
    expect{marta_fire(:open_page)}.to raise_error(ArgumentError, message)
  end

  it 'can open page using predefined url', :need_browser do
    Test_object.new.open_page
    expect(@browser.url).to eq "about:blank"
  end

  it 'can open page using base url and path', :need_browser do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder"
    Test_object2.new.open_page
    expect(@browser.title).to eq "Page five"
  end

  it 'prefers given url over @base_url and @url', :need_browser do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder"
    Test_object3.new.open_page("localhost")
    expect(@browser.url).not_to eq "about:blank"
    expect(@browser.title).not_to eq "Page five"
  end

  it 'prefers @url over @base_url', :need_browser do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder"
    Test_object3.new.open_page
    expect(@browser.url).to eq "about:blank"
  end

  it 'is opening base url when there is no path provided', :need_browser do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder"
    Xpath.new.open_page
    expect(@browser.text.include?("page_five.html")).to be true
  end
end

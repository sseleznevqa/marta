require 'spec_helper'

describe Marta::SmartPage, :need_browser do
  it 'can open pages by url' do
    marta_fire(:open_page, "about:blank")
    expect(@browser.url).to eq "about:blank"
  end

  it 'cannot open pages without any url' do
    message = "You should set url to use open_page. You may"\
    " also use base_url option for dance_with and path for page object"
    expect{marta_fire(:open_page)}.to raise_error(ArgumentError, message)
  end

  it 'can open page using predefined url' do
    page = Test_object.new.open_page
    expect(@browser.url).to eq "about:blank"
    expect(page.class).to eq Test_object
  end

  it 'can open page using base url and path' do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder"
    Test_object2.new.open_page
    expect(@browser.title).to eq "Page five"
  end

  it 'prefers given url over @base_url and @url' do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder"
    Test_object3.new.open_page("localhost")
    expect(@browser.url).not_to eq "about:blank"
    expect(@browser.title).not_to eq "Page five"
  end

  it 'prefers @url over @base_url' do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder"
    Test_object3.new.open_page
    expect(@browser.url).to eq "about:blank"
  end

  it 'is opening base url when there is no path provided' do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder"
    Xpath.new.open_page
    expect(@browser.text.include?("page_five.html")).to be true
  end

  it 'can open page and object using predefined url' do
    page = Test_object.open_page
    expect(@browser.url).to eq "about:blank"
    expect(page.class).to eq Test_object
  end

  it 'can open page and object using base url and path' do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder"
    page = Test_object2.open_page
    expect(@browser.title).to eq "Page five"
    expect(page.class).to eq Test_object2
  end

  it 'is opening base url when there is no path provided' do
    Xpath.open_page("about:blank")
    expect(@browser.url).to eq "about:blank"
  end

  it "Can open page by a base url when page is empty" do
    dance_with base_url: "file://#{Dir.pwd}/spec/test_data_folder/page_five.html"
    page = Test_object4.open_page
    expect(@browser.title).to eq "Page five"
  end
end

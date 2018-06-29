require 'spec_helper'

describe Marta::SmartPage do
  before(:all) do
    @folder = './spec/test_data_folder/temp_test_data_folder'
    @folder_2 = './spec/test_data_folder/delete_me'
    FileUtils.rm_rf(@folder)#Let's be sure that there is no @folder
    @page_three_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_three.html"
  end

  it 'can change tolerancy for searching' do
    dance_with tolerancy: 777
    expect(marta_fire(:tolerancy_value)).to eq 777
  end

  it 'can change folder at flight (and create it too)' do
    dance_with folder: @folder
    expect(marta_fire(:pageobjects_folder)).to eq @folder
    expect(File.directory?(@folder)).to be true
  end

  it 'can switch learn option to true' do
    dance_with clear: true
    expect(marta_fire(:learn_status)).to be false
    dance_with learn: true
    expect(marta_fire(:learn_status)).to be true
  end

  it 'can switch learn option to false when browser is not default' do
    dance_with clear: true, learn: true
    expect(marta_fire(:learn_status)).to be true
    dance_with learn: false, browser: "A wrong one"
    expect(marta_fire(:learn_status)).to be false
  end

  it 'can change browser to almost anything' do
    dance_with browser: 'crocodile'
    expect(marta_fire(:engine)).to eq 'crocodile'
  end

  it 'can change basic url option to a string' do
    dance_with base_url: "String"
    expect(marta_fire(:base_url)).to eq 'String'
  end

  it 'cannot change basic url option to something that is not a string' do
    message = "The value should be a String. Not a 1:Integer"
    expect{dance_with(base_url: 1)}.to raise_error(ArgumentError, message)
  end

  it 'can change cold_timeout option to a integer' do
    dance_with cold_timeout: 9
    expect(marta_fire(:cold_timeout)).to eq 9
  end

  it 'cannot change cold_timout to sommething that is not a Integer' do
    message = 'The value should be a Integer. Not a 91:String'
    expect{dance_with(cold_timeout: "91")}.to raise_error(ArgumentError, message)
  end

  it "can remember a specific port for server" do
    dance_with port: 10011
    expect(marta_fire(:port)).to eq 10011
  end

  it 'can change browser to almost anything except nil', :need_browser do
    dance_with browser: nil
    expect(marta_fire(:engine).class).to eq Watir::Browser
    marta_fire(:engine).quit
  end

  #I need more specific tests for iframe
  it 'can change browser to iframe and back.', :need_browser do
    iframe = @browser.iframe
    expect{dance_with browser: iframe}.
                       to raise_error(Watir::Exception::UnknownFrameException)
    @browser.goto @page_three_url
    dance_with browser: iframe
    expect(marta_fire(:engine).class).to eq Watir::IFrame
    dance_with browser: iframe.browser
    expect(marta_fire(:engine).class).to eq Watir::Browser
  end

  it 'is destroying old browser when new one is provided', :need_browser do
    dance_with(browser: Watir::Browser.new(:chrome))
    expect{@browser.url}.to raise_error(Watir::Exception::Error,
                                    "browser was closed")
  end

  it 'works normally when browser is already closed', :need_browser do
    @browser.quit
    expect{dance_with(browser: Watir::Browser.new(:chrome))}.not_to raise_error
  end

  it 'works correctly in different threads' do
    b = dance_with(tolerancy: 777, folder: @folder, browser: 'crocodile',
               learn: false, base_url: 'Hello', cold_timeout: 11, port: 10013)
    thread = Thread.new do
      b = dance_with(tolerancy: 888, folder: @folder_2, browser: 'cat',
                 learn: false, base_url: 'Good bye', cold_timeout: 12,
                 port: 10014)
      expect(marta_fire(:tolerancy_value)).to eq 888
      expect(marta_fire(:engine)).to eq 'cat'
      expect(marta_fire(:learn_status)).to be false
      expect(marta_fire(:pageobjects_folder)).to eq @folder_2
      expect(marta_fire(:base_url)).to eq 'Good bye'
      expect(marta_fire(:cold_timeout)).to eq 12
      expect(marta_fire(:port)).to eq 10014
    end
    expect(marta_fire(:tolerancy_value)).to eq 777
    expect(marta_fire(:engine)).to eq 'crocodile'
    expect(marta_fire(:learn_status)).to be false
    expect(marta_fire(:pageobjects_folder)).to eq @folder
    expect(marta_fire(:base_url)).to eq 'Hello'
    expect(marta_fire(:cold_timeout)).to eq 11
    expect(marta_fire(:port)).to eq 10013
    thread.join
  end

  it 'uses default variables when nothing is provided' do
    dance_with(tolerancy: 777, folder: @folder, browser: 'crocodile',
               learn: false, base_url: 'Hello', cold_timeout: 11, port: 10013)
    dance_with clear: true
    expect(marta_fire(:tolerancy_value)).to eq 1024
    expect(marta_fire(:engine).class).to eq Watir::Browser
    expect(marta_fire(:learn_status)).to be false
    expect(marta_fire(:pageobjects_folder)).to eq 'Marta_s_pageobjects'
    expect(marta_fire(:base_url)).to eq ''
    expect(marta_fire(:cold_timeout)).to eq 10
    expect(marta_fire(:port)).to eq 6263
    marta_fire(:engine).quit
  end

  after(:all) do
    FileUtils.rm_rf(@folder)
    FileUtils.rm_rf(@folder_2)
  end
end

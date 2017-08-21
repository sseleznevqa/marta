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
    expect(marta_fire(:learn_status)).to be false
    dance_with learn: true
    expect(marta_fire(:learn_status)).to be true
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
    message = "Basic url at least should be a string. Not a 1:Fixnum"
    expect{dance_with(base_url: 1)}.to raise_error(ArgumentError, message)
  end

  it 'can change browser to almost anything except nil', :need_browser do
    dance_with browser: nil
    expect(marta_fire(:engine).class).to eq Watir::Browser
    marta_fire(:engine).close
  end

  #I need more specific tests for iframe
  it 'can change browser to iframe and back.', :need_browser do
    iframe = @browser.iframe
    expect{dance_with browser: iframe}.to raise_error
    @browser.goto @page_three_url
    dance_with browser: iframe
    expect(marta_fire(:engine).class).to eq Watir::IFrame
    dance_with browser: iframe.browser
    expect(marta_fire(:engine).class).to eq Watir::Browser
  end

  it 'works correctly in different threads' do
    dance_with(tolerancy: 777, folder: @folder, browser: 'crocodile',
               learn: true, base_url: 'Hello')
    Thread.new do
      dance_with(tolerancy: 888, folder: @folder_2, browser: 'cat',
                 learn: false, base_url: 'Good bye')
      expect(marta_fire(:tolerancy_value)).to eq 888
      expect(marta_fire(:engine)).to eq 'cat'
      expect(marta_fire(:learn_status)).to be false
      expect(marta_fire(:pageobjects_folder)).to eq @folder_2
      expect(marta_fire(:base_url)).to eq 'Good bye'
    end
    expect(marta_fire(:tolerancy_value)).to eq 777
    expect(marta_fire(:engine)).to eq 'crocodile'
    expect(marta_fire(:learn_status)).to be true
    expect(marta_fire(:pageobjects_folder)).to eq @folder
    expect(marta_fire(:base_url)).to eq 'Hello'
  end

  after(:all) do
    FileUtils.rm_rf(@folder)
    FileUtils.rm_rf(@folder_2)
  end
end

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
    marta_fire(:dance_with, tolerancy: 777)
    expect(marta_fire(:tolerancy_value)).to eq 777
  end

  it 'can change folder at flight (and create it too)' do
    marta_fire(:dance_with, folder: @folder)
    expect(marta_fire(:pageobjects_folder)).to eq @folder
    expect(File.directory?(@folder)).to be true
  end

  it 'can switch learn option to true' do
    expect(marta_fire(:learn_status)).to be false
    marta_fire(:dance_with, learn: true)
    expect(marta_fire(:learn_status)).to be true
  end

  it 'can change browser to almost anything' do
    marta_fire(:dance_with, browser: 'crocodile')
    expect(marta_fire(:engine)).to eq 'crocodile'
  end

  it 'can change browser to almost anything except nil', :need_browser do
    marta_fire(:dance_with, browser: nil)
    expect(marta_fire(:engine).class).to eq Watir::Browser
    marta_fire(:engine).close
  end

  #I need more specific tests for iframe
  it 'can change browser to iframe and back.', :need_browser do
    iframe = @browser.iframe
    expect{marta_fire(:dance_with, browser: iframe)}.to raise_error
    @browser.goto @page_three_url
    marta_fire(:dance_with, browser: iframe)
    expect(marta_fire(:engine).class).to eq Watir::IFrame
    marta_fire(:dance_with, browser: iframe.browser)
    expect(marta_fire(:engine).class).to eq Watir::Browser
  end

  it 'works correctly in different threads' do
    marta_fire(:dance_with, tolerancy: 777,
                            folder: @folder,
                            browser: 'crocodile',
                            learn: true)
    expect(marta_fire(:tolerancy_value)).to eq 777
    expect(marta_fire(:engine)).to eq 'crocodile'
    expect(marta_fire(:learn_status)).to be true
    expect(marta_fire(:pageobjects_folder)).to eq @folder


    Thread.new do
      marta_fire(:dance_with, tolerancy: 888,
                              folder: @folder_2,
                              browser: 'cat',
                              learn: false)
      expect(marta_fire(:tolerancy_value)).to eq 888
      expect(marta_fire(:engine)).to eq 'cat'
      expect(marta_fire(:learn_status)).to be false
      expect(marta_fire(:pageobjects_folder)).to eq @folder_2
    end
  end

  after(:all) do
    FileUtils.rm_rf(@folder)
    FileUtils.rm_rf(@folder_2)
  end
end

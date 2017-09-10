require 'spec_helper'

describe Marta::SmartPage, :need_browser do

  before(:all) do
    @page_five_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_five.html"
  end

  before(:each) do
    @browser.goto @page_five_url
    @syring = Marta::Injector::Syringe.new(@browser, 'for_test', 'title',
                                          'nil||"data"', marta_fire(:gem_libdir),
                                          ["wild_tiger": '"Joe"'],
                                          ["document.title = document.wild_tiger;"])
  end

  # If it is failed. Are u sure that rake install was performed?
  # It will work only if gem is installed.

  it 'is injecting html' do
    @syring.actual_injection
    expect(@browser.text.include?("INJECT")).to be true
  end

  it 'is injecting js and some title' do
    @syring.actual_injection
    expect(@browser.text.include?("title")).to be true
  end

  it 'is injecting js and some data' do
    @syring.actual_injection
    expect(@browser.text.include?("data")).to be true
  end

  it 'is injecting additional vars and scripts' do
    @syring.actual_injection
    expect(@browser.title == "Joe").to be true
  end

  it 'is injecting style' do
    # Sorry. I do not know how to check it now :)
  end

  it 'is injecting html and js all data and gets a result' do
    result = marta_fire(:inject, 'for_test', 'title', '"data"',
                                 ["wild_tiger": '"Joe"'],
                                 ["document.title = document.wild_tiger;"])
    expect(@browser.text.include?("INJECT")).to be true
    expect(@browser.text.include?("title")).to be true
    expect(@browser.text.include?("data")).to be true
    expect(@browser.title == "Joe").to be true
    expect(result).to eq 'Done'
  end

  it 'can reinject staff if it is viped by ajax' do
    @browser.execute_script('document.getElementById("reloadcheck").innerHTML = "not reloaded"')
    expect(@browser.text.include?("not reloaded")).to be true
    expect(@browser.text.include?("Hi, there.")).to be false
    @browser.execute_script('setTimeout(function() { window.location.reload(true); }, 1500);')
    result = marta_fire(:inject, 'for_test', 'title', '"data"')
    expect(result).to eq 'Done'
    expect(@browser.text.include?("not reloaded")).to be false
    expect(@browser.text.include?("Hi, there.")).to be true
  end
end

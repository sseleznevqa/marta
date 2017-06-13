require "simplecov"
SimpleCov.start
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'marta'
require 'rspec'

RSpec.configure do |config|

  config.before do |example|
    include Marta
    if example.metadata[:need_browser]
      @browser = Watir::Browser.new :chrome
    else
      @browser = "We do not need real browser for the test"
    end
    #We will not work with windows... for now
    folder = "./spec/test_data_folder/test_pageobjects"
    marta_fire(:dance_with, browser: @browser, folder: folder, learn: false)
  end
  config.after do |example|
    if example.metadata[:need_browser]
      @browser.close
    end
  end
end

def marta_fire(what, *args)
  Marta::SmartPage.new.send(what, *args)
end

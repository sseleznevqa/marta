require "simplecov"
SimpleCov.start
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'marta'
require 'rspec'

RSpec.configure do |config|
  config.include Marta

  config.before do |example|
    include Marta
    if example.metadata[:need_browser]
      while @browser.nil?
        begin
          @browser = Watir::Browser.new :chrome
        rescue
          @browser = nil
        end
      end
    else
      @browser = "We do not need real browser for the test"
    end
    #We will not work with windows... for now
    folder = "./spec/test_data_folder/test_pageobjects"
    dance_with(browser: @browser, folder: folder, learn: false,
               tolerancy: 1024, base_url: "", cold_timeout: 10)
  end
  config.after do |example|
    if example.metadata[:need_browser]
      @browser.close
    end
  end
end

def marta_fire(what, *args)
  Marta::SmartPage.new("Dummy", ({"vars" => {},"meths" => {}}), false).send(what, *args)
end

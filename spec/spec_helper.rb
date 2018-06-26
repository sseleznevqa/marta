require "simplecov"
SimpleCov.start
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'marta'
require 'rspec'

RSpec.configure do |config|
  config.include Marta

  config.before do |example|
    include Marta
    folder = "./spec/test_data_folder/test_pageobjects"
    if example.metadata[:need_browser]
      @browser = dance_with(folder: folder, learn: false, tolerancy: 1024,
                 base_url: "", cold_timeout: 10, clear: true)
    elsif example.metadata[:need_only_browser]
      @browser = Watir::Browser.new
    else
      @browser = "We do not need real browser for the test"
    end
    #We will not work with windows... for now
    folder = "./spec/test_data_folder/test_pageobjects"
  end
  config.after do |example|
    if example.metadata[:need_browser] or example.metadata[:need_only_browser]
      @browser.quit
    end
  end
end

def marta_fire(what, *args)
  Marta::SmartPage.new("Dummy", ({"vars" => {},"meths" => {}}), false).send(what, *args)
end

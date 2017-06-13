$LOAD_PATH.unshift File.expand_path('../../p_object', __FILE__)
require 'marta'
require 'rspec'
include Marta
RSpec.configure do |config|
  config.before do |example|
    folder = "./spec/p_object/pageobjects"
    dance_with(folder: folder)
    require 'test_page'
  end
end

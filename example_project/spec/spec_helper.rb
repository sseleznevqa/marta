$LOAD_PATH.unshift File.expand_path('../../p_object', __FILE__)
require 'marta'
require 'rspec'
include Marta
RSpec.configure do |config|
  config.before do |example|
    @port = 7000
    folder = "./spec/p_object/pageobjects"
    dance_with(folder: folder, port: @port, base_url: "localhost:#{@port}")
    require 'test_page'
  end
end

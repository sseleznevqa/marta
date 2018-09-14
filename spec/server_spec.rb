require 'marta/server'
require 'marta/options_and_paths'
require 'net/http'

require 'spec_helper'

describe Marta::Server::MartaServer do

  after(:each) do
    Marta::Server::MartaServer.thread.kill
  end

  it 'Cannot be started with wrong port' do
    server = Marta::Server::MartaServer.new(-1000000)
    sleep 10 # We'll give webrick some time to understand that port is not ok
    expect{Marta::Server::MartaServer.server_check}.to raise_error(RuntimeError)
  end

  it "Can run server when everything is correct" do
    server = Marta::Server::MartaServer.new(10001)
    sleep 10 # We'll give webrick some time to understand that port is not ok
    expect{Marta::Server::MartaServer.server_check}.to_not raise_error
    expect(Marta::Server::MartaServer.thread.class).to eq Thread
  end

  it "Can listen to false requests" do
    server = Marta::Server::MartaServer.new(10001)
    thread = Thread.new do
      sleep 1
      url = URI.parse('http://localhost:10001/dialog/not_answer')
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
    end
    expect(Marta::Server::MartaServer.wait_user_dialog_response).to eq false
  end

  it "Can listen to true requests" do
    server = Marta::Server::MartaServer.new(10001)
    thread = Thread.new do
      sleep 1
      url = URI.parse('http://localhost:10001/dialog/got_answer')
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
    end
    expect(Marta::Server::MartaServer.wait_user_dialog_response).to eq true
  end

  it "returns nothing when no requests were placed" do
    server = Marta::Server::MartaServer.new(10001)
    expect(Marta::Server::MartaServer.wait_user_dialog_response(1)).
                                                                   to eq nil
  end

  it "Killing the server mercilessly" do
    server = Marta::Server::MartaServer.new(10101)
    server.server_kill
    url = URI.parse('http://localhost:10101/dialog/got_answer')
    req = Net::HTTP::Get.new(url.to_s)
    expect{Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)}}.to raise_error Errno::ECONNREFUSED
  end


end

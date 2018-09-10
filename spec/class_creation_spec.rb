require 'spec_helper'

describe Marta::SmartPage do

  before(:all) do
    @full_name = "./spec/test_data_folder/test_pageobjects/Json2Class.json"
    @bad_name = "./spec/test_data_folder/test_pageobjects/Bad.json"
    @fake_name = "./spec/test_data_folder/test_pageobjects/Fake.json"
    @page_three_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_three.html"
    donor_name = './spec/test_data_folder/test_pageobjects/Page_three_all.json'
    file = File.read(donor_name)
    @temp_hash = JSON.parse(file)
    #Monkeypatch!
    module Marta
      class SmartPage
        alias umd_saved user_method_dialogs
        def user_method_dialogs(method_name)
          donor_name = './spec/test_data_folder/test_pageobjects/Page_three.json'
          file = File.read(donor_name)
          temp_hash = JSON.parse(file)
          @data['meths'].merge!(temp_hash['meths'])
          @data
        end
      end
    end
    module Marta
      class SmartPage
        alias paed_saved page_edit
        def page_edit(*args)
          #Nothing interesting here
        end
      end
    end
  end

  after(:all) do
    #Reverting monkeypatch :(
    module Marta
      class SmartPage
        alias user_method_dialogs umd_saved
      end
    end

    module Marta
      class SmartPage
        alias page_edit paed_saved
      end
    end
  end

  it 'will do nothing if json file is incorrect' do
    marta_fire(:json_2_class, @bad_name, false)
    expect{Bad.new}.to raise_error(NameError, "uninitialized constant Bad")
  end

  it 'will do nothing if json file does not exist' do
    marta_fire(:json_2_class, @fake_name, false)
    expect{Fake.new}.to raise_error(NameError, "uninitialized constant Fake")
  end

  it 'can create a special class out of json file' do
    marta_fire(:json_2_class, @full_name, false)
    expect{Json2Class.new}.to_not raise_error
  end

  it 'can create class with default info' do
    Marta::SmartPage.new("TestClass")
  end

  it 'can create correct SmartPgae class by user data' do
    page = Marta::SmartPage.new("TestClass",
                      ({"meths"=>{"megameths"=>{"granny"=>{},
                       "options"=>{"collection"=>false,"granny"=>"HTML",
                       "pappy"=>"BODY","self"=>"H1"},"pappy"=>{},
                       "self"=>{}}},"vars"=>{"test"=>"100"}}), false)
    expect(page.methods.include?(:megameths)).to be true
    expect(page.test).to eq "100"
  end

  context 'is creating class with some features like: ' do
    before(:all) do
    end

    before(:each) do
      marta_fire(:json_2_class, @full_name, false)
      @class = Json2Class.new
    end

    it 'possibility to build things' do
      @class.send(:build_content, @temp_hash)
      expect(@class.new_var).to eq "!"
      expect((defined? @class.iframe).nil?).to eq(false)
      expect((defined? @class.iframe_exact).nil?).to eq(false)
    end

    it 'possibility to build methods' do
      @class.send(:build_methods, @temp_hash['meths'])
      expect((defined? @class.iframe).nil?).to eq(false)
      expect((defined? @class.iframe_exact).nil?).to eq(false)
    end

    it 'possibility to build vars' do
      @class.send(:build_vars, @temp_hash['vars'])
      expect(@class.new_var).to eq "!"
    end

    it 'possibility to build one method' do
      @class.send(:build_method, 'oops', @temp_hash['meths']['broken'])
      expect((defined? @class.oops).nil?).to eq(false)
      expect((defined? @class.oops_exact).nil?).to eq(false)
    end

    it 'possibility to build one var' do
      @class.send(:build_var, "attack", "pew-pew!")
      expect(@class.attack).to eq "pew-pew!"
      @class.send(:build_var, "attack", "boom!")
      expect(@class.attack).to eq "boom!"
      @class.send(:build_var, "methods", "boom!")
      expect(@class.methods).to_not eq 'boom!'
    end

    it 'possibility to strip desired method name' do
      expect(@class.send(:correct_name, "attack")).to eq "attack"
      expect(@class.send(:correct_name, "attack_exact")).to eq "attack"
      expect(@class.send(:correct_name, "attack_exactr")).to eq "attack_exactr"
    end

    it 'vars', :need_browser do
      @browser.goto @page_three_url
      expect(@class.var).to eq "something"
      expect(@class.othervar).to eq "somethingother"
      expect{@class.var, @class.othervar = "1","2"}.to_not raise_error
      expect(@class.var).to eq "1"
      expect(@class.othervar).to eq "2"
      expect(@class.class).to_not eq 'ignored'
      expect(@class.not_welcome).to_not eq 'ignored'
    end

    it 'methods', :need_browser do
      @browser.goto @page_three_url
      expect((defined? @class.not_welcome).nil?).to eq(false)
      expect(@class.not_welcome.class).to eq Watir::Heading
    end

    it 'exact_methods', :need_browser do
      @browser.goto @page_three_url
      expect((defined? @class.not_welcome_exact).nil?).to eq(false)
      expect(@class.not_welcome_exact.class).to eq Watir::Heading
    end

    it 'method_edit (creating methods)', :need_browser do
      @browser.goto @page_three_url
      expect(@class.method_edit("hello_world").class).to eq Watir::Heading
      expect((defined? @class.hello_world).nil?).to eq(false)
      expect((defined? @class.hello_world_exact).nil?).to eq(false)
      expect(@class.hello_world.class).to eq Watir::Heading
    end

    it 'method_edit (creating methods) from _exact', :need_browser do
      @browser.goto @page_three_url
      expect(@class.method_edit("hello_world_exact").class).to eq Watir::Heading
      expect((defined? @class.hello_world).nil?).to eq(false)
      expect((defined? @class.hello_world_exact).nil?).to eq(false)
    end
  end
  context 'teaching when learn is enabled', need_only_browser: false do

    before(:each) do
      dance_with clear: true, learn: true
      marta_fire(:json_2_class, @full_name, true)
      @learn_class = Json2Class.new
      def @learn_class.marta_magic_finder(*args)
        'Result'
      end
      def @learn_class.marta_simple_finder(*args)
        'Result2'
      end
    end

    before(:all) do
      marta_fire(:json_2_class, @full_name, false)
      @class = Json2Class.new
    end

    after(:all) do
      dance_with learn: false
    end

    it 'methods' do
      expect((defined? @learn_class.not_welcome).nil?).to eq(false)
      expect(@learn_class.not_welcome).to eq 'Result'
    end

    it 'exact_methods' do
      expect((defined? @learn_class.not_welcome_exact).nil?).to eq(false)
      expect(@learn_class.not_welcome_exact).to eq 'Result2'
    end
  end
end

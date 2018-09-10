require 'spec_helper'

describe Marta::SmartPage, :need_browser do

  before(:all) do
    @page_three_url = "file://#{Dir.pwd}/spec/test_data_folder/page_three.html"
    @page_ten_url = "file://#{Dir.pwd}/spec/test_data_folder/page_ten.html"
    donor_name = './spec/test_data_folder/test_pageobjects/Page_three_all.json'
    file = File.read(donor_name)
    temp_hash = JSON.parse(file)
    @correct = temp_hash['meths']['correct']
    @correct_collection = temp_hash['meths']['correct_collection']
    @xpath = temp_hash['meths']['xpath']
    @xpath_collection = temp_hash['meths']['xpath_collection']
    @broken = temp_hash['meths']['broken']
    @broken_collection = temp_hash['meths']['broken_collection']
    @iframe = temp_hash['meths']['iframe']
    @nots = temp_hash['meths']['nots_span']
    @broken_nots = temp_hash['meths']['broken_nots_span']
    @nots_collection = temp_hash['meths']['nots_collection']
    @broken_nots_collection = temp_hash['meths']['broken_nots_collection']
    @smart = temp_hash['meths']['smart']
    @smart_class = temp_hash['meths']['smart_class']
  end

  before(:each) do
    @browser.goto @page_three_url
  end

  it 'can find a correct element' do
    element = marta_fire(:marta_magic_finder, @correct)
    expect(element.class).to eq Watir::Heading
    expect(element.exists?).to be true
  end

  it 'can find a correct collection' do
    element = marta_fire(:marta_magic_finder, @correct_collection)
    expect(element.class).to eq Watir::HTMLElementCollection
    expect(element[0].exists?).to be true
    expect(element.count).to be 1
  end

  it 'can find a correct element by xpath' do
    element = marta_fire(:marta_magic_finder, @xpath)
    expect(element.class).to eq Watir::Heading
    expect(element.exists?).to be true
  end

  it 'can find a correct collection by xpath' do
    element = marta_fire(:marta_magic_finder, @xpath_collection)
    expect(element.class).to eq Watir::HTMLElementCollection
    expect(element[0].exists?).to be true
    expect(element.length).to be 1
  end

  it 'can find a broken element' do
    element = marta_fire(:marta_magic_finder, @broken)
    expect(element.class).to eq Watir::Heading
    expect(element.exists?).to be true
  end

  it 'can find a broken collection' do
    element = marta_fire(:marta_magic_finder, @broken_collection)
    expect(element.class).to eq Watir::HTMLElementCollection
    expect(element[0].exists?).to be true
    expect(element.length).to be 1
  end

  it 'treats iframes correctly' do
    element = marta_fire(:marta_magic_finder, @iframe)
    expect(element.class).to eq Watir::IFrame
    expect{element.switch_to!}.to_not raise_error
  end

  it 'can find a correct element with nots' do
    element = marta_fire(:marta_magic_finder, @nots)
    expect(element.class).to eq Watir::Span
    expect(element.exists?).to be true
  end

  it 'can find a broken element with nots' do
    element = marta_fire(:marta_magic_finder, @broken_nots)
    expect(element.class).to eq Watir::Span
    expect(element.exists?).to be true
  end

  it 'can find s correct collection with nots' do
    element = marta_fire(:marta_magic_finder, @nots_collection)
    expect(element.class).to eq Watir::HTMLElementCollection
    expect(element[0].exists?).to be true
    expect(element.length).to be 1
  end

  it 'can find a broken collection with nots' do
    element = marta_fire(:marta_magic_finder, @broken_nots_collection)
    expect(element.class).to eq Watir::HTMLElementCollection
    expect(element[0].exists?).to be true
    expect(element.length).to be 1
  end

  it 'can find element with changed attribute name' do
    element = marta_fire(:marta_magic_finder, @smart)
    expect(element.attribute_value("notid")).to eq "id"
  end

  it 'can find element with changed attribute name (class related)' do
    element = marta_fire(:marta_magic_finder, @smart_class)
    expect(element.attribute_value("notclass")).to eq "aa zz"
  end

  context 'Auto learn feature' do
    before(:each) do
      @name = 'Toedit'
      @full_name = "./spec/test_data_folder/test_pageobjects/#{@name}.json"
      @data = {"vars": {},
               "meths":{"h1" => {'options' => {'collection' => false},
                        'positive' => {
                          'self' => {
                            'text'=>[], 'tag' => ["H1"], 'attributes' => {"id" => ["wrong"]}},
                           'pappy' => {
                             'text'=>[], 'tag' => [], 'attributes' => {}},
                           'granny' => {
                             'text'=>[], 'tag' => [], 'attributes' => {}}},
                         'negative' => {
                           'self' => {
                             'text'=>[], 'tag' => [], 'attributes' => {}},
                            'pappy' => {
                              'text'=>[], 'tag' => [], 'attributes' => {}},
                            'granny' => {
                              'text'=>[], 'tag' => [], 'attributes' => {}}}
                           }}}
      Marta::OptionsAndPaths::SettingMaster.
                      set_folder "./spec/test_data_folder/test_pageobjects/"
      File.open(@full_name,"w") do |f|
        f.write(JSON.pretty_generate(@data))
      end
      dance_with
      @browser.goto @page_ten_url
    end
    after(:each) do
      FileUtils.rm_rf(@full_name)
    end

    it 'somewhere at magic find we are silently rewriting broken js' do
      Toedit.new.h1
      file = File.read(@full_name)
      data_hash = JSON.parse(file)
      check_data = data_hash['meths']['h1']['positive']
      expect(check_data['self']['tag'][0]).to eq "H1"
      expect(check_data['self']['attributes']['id']).to eq []
      expect(check_data['self']['attributes']['class']).to eq ['hello', 'world']
      expect(check_data['pappy']['tag'][0]).to eq "SPAN"
      expect(check_data['granny']['tag'][0]).to eq "DIV"
    end
  end
end

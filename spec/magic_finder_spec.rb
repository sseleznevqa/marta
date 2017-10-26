require 'spec_helper'

describe Marta::SmartPage, :need_browser do

  before(:all) do
    @page_three_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_three.html"
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
    expect(element.length).to be 1
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
end

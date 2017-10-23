require 'spec_helper'

describe Marta::SmartPage, :need_browser do

  before(:all) do
    @page_three_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_three.html"
    donor_name = './spec/test_data_folder/test_pageobjects/Page_three_all.json'
    file = File.read(donor_name)
    temp_hash = JSON.parse(file)
    @method = temp_hash['meths']['correct']
    @method_with_collection = temp_hash['meths']['correct_collection']
    @iframe = temp_hash['meths']['iframe']
    @collection_with_nots = temp_hash['meths']['nots_collection']
    @element_with_nots = temp_hash['meths']['nots_span']
    @broken = temp_hash['meths']['broken']
  end

  before(:each) do
    @browser.goto @page_three_url
  end

  it 'can find element' do
    result = marta_fire(:marta_simple_finder, @method).class
    expect(result).to eq Watir::Heading
  end

  it 'can find collection' do
    result = marta_fire(:marta_simple_finder, @method_with_collection).class
    expect(result).to eq Watir::HTMLElementCollection
  end

  it 'treats iframes correctly all the times :)' do
    element = marta_fire(:marta_simple_finder, @iframe)
    expect(element.class).to eq Watir::IFrame
    expect{element.switch_to!}.to_not raise_error
  end

  it 'can find collection with nots' do
    result = marta_fire(:marta_simple_finder, @collection_with_nots)
    expect(result.class).to eq Watir::HTMLElementCollection
    expect(result.length).to eq 1
  end

  it 'can find an element with nots' do
    result = marta_fire(:marta_simple_finder, @element_with_nots).class
    expect(result).to eq Watir::Span
  end

  it 'is not failing when there is no element' do
    expect{marta_fire(:marta_simple_finder, @broken)}.to_not raise_error
  end

end

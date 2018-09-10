require 'spec_helper'

describe Marta::SmartPage, :need_browser do

  before(:all) do
    @page_three_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_three.html"
    @page_six_url = "file://#{Dir.pwd}/spec/test_data_folder/page_six.html"
  end

  before(:each) do
    @browser.goto @page_three_url
  end

  it 'can highlight element' do
    marta_fire(:highlight, @browser.element(id:"element1"))
    martaclass = @browser.element(id:"element1").attribute_value("martaclass")
    expect(martaclass).to eq "foundbymarta"
  end

  it 'can unhighlight element' do
    marta_fire(:unhighlight, @browser.element(id:"element1"))
    martaclass = @browser.element(id:"element1").attribute_value("martaclass")
    expect(martaclass.nil?).to be true
  end

  it 'has no problem with highlighting nothing' do
    expect{marta_fire(:highlight, @browser.element(id:"noelement"))}.not_to raise_error
  end

  it 'has no problem with unhighlighting nothing' do
    expect{marta_fire(:unhighlight, @browser.element(id:"noelement"))}.not_to raise_error
  end

  it 'can perform a massive highlight' do
    mass = @browser.elements(name: "findme")
    marta_fire(:mass_highlight_turn, mass)
    mass.each do |item|
      martaclass = item.attribute_value("martaclass")
      expect(martaclass).to eq "foundbymarta"
    end
  end

  it 'can perform a massive unhighlight' do
    mass = @browser.elements(name: "findme")
    marta_fire(:mass_highlight_turn, mass, false)
    mass.each do |item|
      expect(item.attribute_value("martaclass")).to eq nil
    end
  end

  it 'ignores lost elements' do
    mass = @browser.elements(name: "findme")
    marta_fire(:mass_highlight_turn, mass)
    mass.each do |item|
      martaclass = item.attribute_value("martaclass")
      expect(martaclass).to eq "foundbymarta"
      @browser.execute_script("arguments[0].parentNode."\
                              "removeChild(arguments[0]);",
                              item)
    end
    expect{marta_fire(:mass_highlight_turn, mass, false)}.to_not raise_error
  end
end

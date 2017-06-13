require 'spec_helper'

describe Marta::SmartPage, :need_browser do

  before(:all) do
    @page_three_url = "file://#{Dir.pwd}" +
      "/spec/test_data_folder/page_three.html"
  end

  before(:each) do
    @browser.goto @page_three_url
  end

  it 'can highlight element' do
    style = marta_fire(:highlight, @browser.element(id:"element1"))
    expect(style).to eq "color: green;"
    installed_style = @browser.element(id:"element1").attribute_value("style")
    expect(installed_style).to eq "animation: marta_found 6s infinite;"
  end

  it 'can unhighlight element' do
    marta_fire(:unhighlight, @browser.element(id:"element1"), "color: black;")
    installed_style = @browser.element(id:"element1").attribute_value("style")
    expect(installed_style).to eq "color: black;"
  end

  it 'can perform a massive highlight' do
    mass = @browser.elements(name: "findme")
    styles = marta_fire(:mass_highlight_turn, mass)
    mass.each do |item|
      style = item.attribute_value("style")
      expect(style).to eq "animation: marta_found 6s infinite;"
    end
    styles.each do |style|
      expect((style == 'color: blue;')||(style == 'color: green;')).to be true
    end
  end

  it 'can perform a massive unhighlight' do
    mass = @browser.elements(name: "findme")
    styles =['color: black;','color: black;']
    styles = marta_fire(:mass_highlight_turn, mass, false, styles)
    mass.each do |item|
      expect(item.attribute_value("style")).to eq "color: black;"
    end
  end
end

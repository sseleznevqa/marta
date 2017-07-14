require 'marta/simple_element_finder'
require 'spec_helper'

describe Marta::SimpleElementFinder::BasicFinder do

  before(:all) do
    @xpath = "//HTML/BODY/H1[contains(@class,'element')]"\
            "[contains(@class,'to')][contains(@class,'find')][@id='element1']"
    @page_three_url = "file://#{Dir.pwd}" +
              "/spec/test_data_folder/page_three.html"
    class Helper
      def newclass(what)
        donor_name = './spec/test_data_folder/test_pageobjects/Page_three_all.json'
        file = File.read(donor_name)
        temp_hash = JSON.parse(file)
        meth = temp_hash['meths'][what]
        Marta::SimpleElementFinder::BasicFinder.new(meth,
          Marta::SmartPage.new('Dummy', ({"vars" => {},"meths" => {}}), false))
      end
    end
    @helper = Helper.new
  end

  it 'knows when we are looking for collection' do
    expect(@helper.newclass('correct_collection').collection?).to be true
  end

  it 'knows when we are looking for a single element' do
    expect(@helper.newclass('correct').collection?).to be false
  end

  it 'knows when we are looking for element by hard xpath' do
    expect(@helper.newclass('xpath').forced_xpath?).to be true
  end

  it 'knows when we are looking for usual element' do
    expect(@helper.newclass('correct').forced_xpath?).to be false
  end

  it 'gets forced xpath when it is provided' do
    expect(@helper.newclass('xpath').xpath_by_meth).to eq "//h1"
  end

  it 'forms xpath with XPathFactory' do
    expect(@helper.newclass('correct').xpath_by_meth).to eq @xpath
  end

  it 'can prefind element', :need_browser do
    expect(@helper.newclass('correct').prefind.class).to eq Watir::HTMLElement
  end

  it 'can prefind a collection', :need_browser do
    expect(@helper.newclass('correct').prefind_collection.class).
      to eq Watir::HTMLElementCollection
  end

  it 'can transfer element to subtype', :need_browser do
    finder = @helper.newclass('iframe')
    element = finder.prefind
    @browser.goto @page_three_url
    expect(finder.subtype_of(element).class).to eq Watir::IFrame
  end

  it 'finds what we need finally (collection)', :need_browser do
    expect(@helper.newclass('correct_collection').find.class).
      to eq Watir::HTMLElementCollection
  end

  it 'finds what we need finally (element)', :need_browser do
    @browser.goto @page_three_url
    finder = @helper.newclass('correct')
    element = finder.find
    expect(element.class).to eq Watir::Heading
  end
end

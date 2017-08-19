require 'marta/black_magic'
require 'spec_helper'

describe Marta::SimpleElementFinder::BasicFinder do

  before(:all) do
    @xpath = "//HTML/BODY/H1[contains(@class,'element')]"\
            "[contains(@class,'to')][contains(@class,'find')][@id='element1']"
    @page_three_url = "file://#{Dir.pwd}" +
              "/spec/test_data_folder/page_three.html"
    @xpath = "//*/BODY/H1[contains(@class,'element')][contains(@class,'find')]"
    @xpath_without_granny =
      "//*/BODY/H1[contains(@class,'element')][contains(@class,'find')]"
    @xpath_without_pappy =
      "//*//*/H1[contains(@class,'element')][contains(@class,'find')]"
    @xpath_with_self =
      "//*//*//H1[contains(@class,'element')][contains(@class,'find')]"

    class Helper
      def newclass(what)
        donor_name =
               './spec/test_data_folder/test_pageobjects/Page_three_all.json'
        file = File.read(donor_name)
        temp_hash = JSON.parse(file)
        meth = temp_hash['meths'][what]
        Marta::BlackMagic::MagicFinder.new(meth, 1024,
          Marta::SmartPage.new('Dummy', ({"vars" => {},"meths" => {}}), false))
      end
    end
    @helper = Helper.new
  end

  it 'waits for prefinded element', :need_browser do
    @browser.goto @page_three_url
    expect(@helper.newclass('correct').prefind_with_waiting.class).
      to eq Watir::HTMLElement
  end

  it 'waits for prefinded element for 10 seconds', :need_browser do
    @browser.goto @page_three_url
    t = Time.now
    @helper.newclass('broken').prefind_with_waiting
    expect(Time.now-t).to be >= 10
  end

  it 'finds a broken element', :need_browser do
    @browser.goto @page_three_url
    expect(@helper.newclass('broken').find.class).to eq Watir::Heading
  end

  context 'forms complex xpaths', :need_browser do
    before(:each) do
      @browser.goto @page_three_url
    end

    it 'can form many xpaths (including a good one!)' do
      xpaths = @helper.newclass('broken').form_complex_xpath(3, true, true)
      expect(xpaths.include?(@xpath)).to eq true
    end

    it 'can form many xpaths without granny (including a good one!)' do
      xpaths = @helper.newclass('broken').form_complex_xpath(2, false, true)
      expect(xpaths.include?(@xpath_without_granny)).to eq true
    end

    it 'can form many xpaths without pappy (including a good one!)' do
      xpaths = @helper.newclass('broken').form_complex_xpath(3, true, false)
      expect(xpaths.include?(@xpath_without_pappy)).to eq true
    end

    it 'can form many xpaths without nobody (including a good one!)' do
      xpaths = @helper.newclass('broken').form_complex_xpath(3, false, false)
      expect(xpaths.include?(@xpath_with_self)).to eq true
    end

    it 'It cannot find anything if there are too many unknowns' do
      expect{@helper.newclass('broken').
        form_complex_xpath(100, false, false)}.to raise_error(RuntimeError)
    end
  end

  it 'manages granny and pappy (true-true case)' do
    granny, pappy = @helper.newclass('broken').granny_pappy_manage(true, true)
    expect(granny).to be false
    expect(pappy).to be true
  end

  it 'manages granny and pappy (false-true case)' do
    granny, pappy = @helper.newclass('broken').granny_pappy_manage(false, true)
    expect(granny).to be true
    expect(pappy).to be false
  end

  it 'manages granny and pappy (true-false case)' do
    granny, pappy = @helper.newclass('broken').granny_pappy_manage(true, false)
    expect(granny).to be false
    expect(pappy).to be false
  end

  it 'manages granny and pappy (false-false case)' do
    expect{@helper.newclass('broken').granny_pappy_manage(false, false)}.
      to raise_error(RuntimeError, "Marta did her best. But she found nothing")
  end

  it 'creates the array of candidates for finding', :need_browser do
    @browser.goto @page_three_url
    xpaths = ["//HTML", "//DUMMY"]
    array1, array2 = @helper.
                         newclass('broken').candidates_arrays_creation(xpaths)
    expect(array1[0].class).to eq Watir::HTMLElement
    expect(array2[0]).to eq "//HTML"
    expect(array1.count). to eq 1
    expect(array2.count). to eq 1
  end

  it 'selects candidates' do
    xpaths = ["//HTML", "//DUMMY", "//HTML"]
    elements = ["good", "dummy", "good"]
    result = @helper.newclass('broken').get_search_result('anything',
                                                             elements, xpaths)
    expect(result).to eq 'good'
  end

  it 'selects no candidates if arrays are empty' do
    result = @helper.newclass('broken').get_search_result('anything', [], [])
    expect(result).to eq 'anything'
  end

  context 'actualy searches', :need_browser do

    before(:each) do
      @browser.goto @page_three_url
      @unknown = @browser.element(xpath: "//thereisnosuchelement")
    end

    it 'can find an element by broken data' do
      element = @helper.newclass('broken').actual_searching(@unknown)
      expect(element.to_subtype.class).to eq Watir::Heading
      expect(element.exists?).to be true
    end

    it 'sometimes can not find element' do
      #Set_tolerancy_here!!!
      expect{@helper.newclass('raise_raise').actual_searching(@unknown)}.
        to raise_error(RuntimeError)
    end
  end

end

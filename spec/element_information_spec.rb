require 'spec_helper'

describe Marta::SmartPage, :need_browser do
  before(:all) do
    @page_url = "file://#{Dir.pwd}/spec/test_data_folder/page_ten.html"
    @hash = {"self"=>{"tag"=>["H1"],
                      "text"=>["\n          HELLO WORLD!\n        "],
                      "attributes"=>{"class"=>["hello", "world"],
                                     "id"=>["header"]}},
             "pappy"=>{"tag"=>["SPAN"],
                       "text"=>[],
                       "attributes"=>{"attribute"=>["attribute"],
                                      "class_attribute"=>["class", "span"]}},
             "granny"=>{"tag"=>["DIV"],
                        "text"=>[],
                        "attributes"=>{"class"=>["class", "div"],
                                       "id"=>["id"]}}}
  end

  it 'can get information about element' do
    @browser.goto @page_url
    element = @browser.element(id: "header")
    hash = marta_fire(:get_attributes, element)
    expect(hash).to eq @hash
  end
end

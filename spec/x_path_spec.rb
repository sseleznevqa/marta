require 'marta/x_path'
require 'spec_helper'

describe Marta::XPath::XPathFactory do

  before(:each) do
    class Requestor
      attr_accessor :element
    end
    @requestor = Requestor.new
    @requestor.element = "element"
    donor_name = './spec/test_data_folder/test_pageobjects/Xpath.json'
    file = File.read(donor_name)
    temp_hash = JSON.parse(file)
    @meth = temp_hash['meths']['hello_world']
    @class = Marta::XPath::XPathFactory.new(@meth, @requestor)
    @self_array = [{full: "/", empty: "//"},
                   {full: "H1", empty: "*"},
                   {full: "[contains(@class,'\#{@element}')]", empty: ""},
                   {full: "[contains(@class,'to')]", empty: ""},
                   {full: "[contains(@class,'find')]", empty: ""},
                   {full: "[@id='element1']", empty: ""},
                   {full: "[contains(text(),'Hello World!')]", empty: ""},
                   {full: "[not(contains(@class,'xx'))]", empty: ""},
                   {full: "[not(@id='elementz')]", empty: ""},
                   {full: "[not(contains(text(),'Bye'))]", empty: ""}]
    @granny_array = [{full:"//",empty:"//"},{full:"HTML",empty:"*"},
                     {:full=>"[not(self::LOL)]", :empty=>""}]
    @pappy_array = [{full:"/",empty:"//"},{full:"BODY",empty:"*"}]
    @not_pappy_array = [{full: "[not(self::BODY)]", empty: ""}]
    @xpath = "//HTML[not(self::LOL)]/BODY/H1[contains(@class,'element')]"\
      "[contains(@class,'to')][contains(@class,'find')][@id='element1']"\
      "[contains(text(),'Hello World!')][not(contains(@class,'xx'))]"\
      "[not(@id='elementz')][not(contains(text(),'Bye'))]"
    @guess_part = [[{full: "//", empty: "//"}, {full: "BODY", empty: "*"}],
                  [{full: "/", empty: "//"}, {full: "*", empty: "*"}]]
    @positive_self = [{full: "/", empty: "//"},
                      {full: "H1", empty: "*"},
                      {full: "[contains(@class,'\#{@element}')]", empty: ""},
                      {full: "[contains(@class,'to')]", empty: ""},
                      {full: "[contains(@class,'find')]", empty: ""},
                      {full: "[@id='element1']", empty: ""},
                      {full: "[contains(text(),'Hello World!')]", empty: ""}]
    @negative_self = [{full: "/", empty: "//"},
                      {full: "H1", empty: "*"},
                      {full: "[contains(@class,'xx')]", empty: ""},
                      {full: "[@id='elementz']", empty: ""},
                      {full: "[contains(text(),'Bye')]", empty: ""}]
  end

  it 'uses default vars' do
    is_set = (@class.pappy) and (@class.granny)
    expect(is_set).to be true
  end

  it 'can form part of array of hashes' do
    granny = @class.get_xpaths(true, 'granny')
    expect(granny).to eq [{full:"/",empty:"//"},
                          {full:"HTML",empty:"*"},
                          {:full=>"[not(self::LOL)]", :empty=>""}]
  end

  it 'forms dummy part of array of hashes sometimes' do
    granny = @class.get_xpaths(false, 'granny')
    expect(granny).to eq [{full:"//",empty:"//"},{full:"*",empty:"*"}]
  end

  it 'treats granny in a special way' do
    granny = @class.create_granny
    expect(granny).to eq [{full:"//",empty:"//"},{full:"HTML",empty:"*"},
                          {:full=>"[not(self::LOL)]", :empty=>""}]
  end

  it 'treats granny as usual when granny option is off' do
    @class.granny = false
    granny = @class.create_granny
    expect(granny).to eq [{full:"//",empty:"//"},{full:"*",empty:"*"}]
  end

  it 'creates pappy' do
    pappy = @class.create_pappy
    expect(pappy).to eq [{full:"/",empty:"//"},{full:"BODY",empty:"*"}]
  end

  it 'creates dummy pappy when it is off' do
    @class.pappy = false
    pappy = @class.create_pappy
    expect(pappy).to eq [{full:"//",empty:"//"},{full:"*",empty:"*"}]
  end

  it 'creates self' do
    expect(@class.create_self).to eq @self_array
  end

  it 'creates joined xpath array' do
    @class.granny = @class.pappy = true
    expect(@class.create_xpath).to eq @granny_array + @pappy_array + @self_array
  end

  it 'forms one guess array with depth = 0' do
    #we are checking content in magic_finder_spec and actual_search_spec
    @class.granny = @class.pappy = false
    expect(@class.form_variants(0).count).to eq 1
  end

  it 'forms more guess arrays with depth = 1' do
    expect(@class.form_variants(1).count).to eq 15
  end

  it 'forms more guess arrays with depth = 2' do
    expect(@class.form_variants(2).count).to eq 106
  end

  it 'forms one guess xpath string with depth = 0' do
    #we are checking content in magic_finder_spec and actual_search_spec
    @class.granny = @class.pappy = false
    expect(@class.generate_xpaths(0).count).to eq 1
  end

  it 'forms more guess xpath strings with depth = 1' do
    expect(@class.generate_xpaths(1).count).to eq 15
  end

  it 'forms more guess xpath strings with depth = 2' do
    expect(@class.generate_xpaths(2).count).to eq 106
  end

  it 'generates plain xpath in one simple call' do
    expect(@class.generate_xpath).to eq @xpath
  end

  it 'creates xpaths from arrays of hashes' do
    expect(@class.form_xpaths_from_array(@pappy_array)).to eq @guess_part
  end

  it 'creates tag part hash array (positive)' do
    expect(@class.form_array_hash_for_tag('BODY', false)).to eq @pappy_array
  end

  it 'creates tag part hash array (negative)' do
    expect(@class.form_array_hash_for_tag('BODY', true)).to eq @not_pappy_array
  end

  it 'forms full array of hashes ' do
    expect(@class.form_array_hash('H1', @meth['self'])).to eq @positive_self
  end

  it 'forms full array of hashes (with nots) ' do
    expect(@class.form_array_hash('H1', @meth['not_self'])).to eq @negative_self
  end

  it 'forms correct attribute part (positive hash)' do
    expect(@class.form_hash_for_attribute('a', 'b', false)).
                                          to eq ({full:"[@a='b']", empty: ""})
  end

  it 'forms correct attribute part (negative hash)' do
    expect(@class.form_hash_for_attribute('a', 'b', true)).
                                      to eq ({full:"[not(@a='b')]", empty: ""})
  end

  it 'forms correct attribute part for text-like atributes' do
    text = 'retrieved_by_marta_text'
    result = ({full:"[contains(text(),'b')]",empty: ""})
    expect(@class.form_hash_for_attribute(text, 'b', false)).to eq result
  end

  it 'forms correct attribute part for text-like atributes (negative case)' do
    text = 'retrieved_by_marta_text'
    result = ({full:"[not(contains(text(),'b'))]",empty: ""})
    expect(@class.form_hash_for_attribute(text, 'b', true)).to eq result
  end

  it 'forms correct attribute parts for class-like attributes' do
    text = 'class-like'
    result = [{full:"[contains(@class-like,'b')]",empty: ""},
              {full:"[contains(@class-like,'a')]",empty: ""}]
    expect(@class.form_array_hash_for_class(text, ['b','a'], false))
                                                                .to eq result
  end

  it 'forms correct attribute parts for class-like attributes with nots' do
    text = 'class-like'
    result = [{full:"[not(contains(@class-like,'b'))]",empty: ""},
              {full:"[not(contains(@class-like,'a'))]",empty: ""}]
    expect(@class.form_array_hash_for_class(text, ['b','a'], true))
                                                                .to eq result
  end

  it 'can form hashes by special rule' do
    expect(@class.make_hash('a','b')).to eq ({full: 'a', empty: 'b'})
  end

end

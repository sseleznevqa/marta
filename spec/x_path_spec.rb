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
    @full = [{:full=>["//"], :empty=>["//"]},
             {:full=>["HTML"], :empty=>["*"]},
             {:full=>["[not(self::LOL)]"], :empty=>[""]},
             {:full=>["/"], :empty=>["//"]},
             {:full=>["BODY"], :empty=>["*"]},
             {:full=>["/"], :empty=>["//"]},
             {:full=>["H1"], :empty=>["*"]},
             {:full=>["[contains(text(),'Hello World!')]"], :empty=>[""]},
             {:full=>["[contains(@class,'\#{@element}')]"],
                     :empty=>["[@*[contains(.,'\#{@element}')]]", ""]},
             {:full=>["[contains(@class,'to')]"],
                     :empty=>["[@*[contains(.,'to')]]", ""]},
             {:full=>["[contains(@class,'find')]"],
                     :empty=>["[@*[contains(.,'find')]]", ""]},
             {:full=>["[contains(@id,'element1')]"],
                     :empty=>["[@*[contains(.,'element1')]]", ""]},
             {:full=>["[not(contains(text(),'Bye'))]"], :empty=>[""]},
             {:full=>["[not(contains(@class,'xx'))]"], :empty=>[""]},
             {:full=>["[not(contains(@id,'elementz'))]"], :empty=>[""]}]
    @no_granny = [@full[0]] + @full[4..-1]
    @no_pappy = @full[0..2] + @full[5..-1]
    @self = [@full[0]] + @full[6..-1]
    @xpath = "//HTML[not(self::LOL)]/BODY/H1[contains(text(),'Hello World!')]"\
             "[contains(@class,'\#{@element}')][contains(@class,'to')]"\
             "[contains(@class,'find')][contains(@id,'element1')]"\
             "[not(contains(text(),'Bye'))][not(contains(@class,'xx'))]"\
             "[not(contains(@id,'elementz'))]"
    @casino_hash =[{full:["1"], empty:["2","3"]},
                   {full:["4"], empty:["5","6"]},
                   {full:["7"], empty:["8","9"]}]
  end

  it 'uses default vars' do
    is_set = (@class.pappy) and (@class.granny)
    expect(is_set).to be true
  end

  it 'creating array of hashes with granny and pappy' do
    array = @class.array_of_hashes
    expect(array).to eq @full
  end

  it 'creating hashes without granny' do
    @class.granny = false
    array = @class.array_of_hashes
    expect(array).to eq @no_granny
  end

  it 'creating hashes without pappy' do
    @class.pappy = false
    array = @class.array_of_hashes
    expect(array).to eq @no_pappy
  end

  it 'creating hashes with self only' do
    @class.pappy = false
    @class.granny = false
    array = @class.array_of_hashes
    expect(array).to eq @self
  end

  it 'is making atom hashes' do
    hash = @class.make_hash(1,2)
    expect(hash).to eq({full:[1],empty:[2]})
  end

  it 'is making atom hashes with arrays of varies' do
    hash = @class.make_hash(1,[2,3])
    expect(hash).to eq({full:[1],empty:[2,3]})
  end

  it 'is making negative parts of xpaths hashes' do
    hash = @class.negative_part_of_array_of_hashes('granny')
    expect(hash).to eq [{:full=>["[not(self::LOL)]"], :empty=>[""]}]
  end

  it 'is making positive parts of xpaths hashes' do
    hash = @class.positive_part_of_array_of_hashes('granny')
    expect(hash).to eq [{full:["HTML"],empty:["*"]}]
  end

  it 'can generate really simpe xpath' do
    xpath = @class.generate_xpath
    expect(xpath).to eq @xpath
  end

  it 'can generate all the xpaths one by one' do
    xpaths = @class.generate_xpaths(2,362)
    expect(xpaths.count).to eq 168
  end

  it 'will try to guess the xpath when there is not enough tolerancy' do
    xpaths = @class.generate_xpaths(2,300)
    expect(((xpaths.count<168) and (xpaths.count>100))).to eq true
  end

  it 'is guessing xpaths sometimes' do # Viva, Las-Vegas!
    xpaths = @class.monte_carlo(@casino_hash, 3, 1000000).uniq
    expect(xpaths.count).to eq 26
  end

  it 'using masks to generate xpaths' do
    xpaths = @class.xpaths_by_mask([:full, :empty, :empty], @casino_hash)
    expect(xpaths.count).to eq 4
  end

  it 'is generating masks' do
    masks = @class.get_masks([[:full,:full,:full]],3)
    expect(masks.uniq.count).to eq 8
  end

  it 'roughly counting is there enough tolerancy' do
    depth, hashes = @class.analyze(2,362)
    expect(depth).to eq 2
    expect(hashes.count).to eq 15
  end

  it 'roughly counting is there enough tolerancy (not enough case)' do
    depth, hashes = @class.analyze(2,300)
    expect(depth).to eq 1
    expect(hashes.count).to eq 15
  end
end

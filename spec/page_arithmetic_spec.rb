require 'spec_helper'

describe Marta do

  before(:each) do
    @first = {'options' => {'collection' => false},
                'positive' => {
                  'self' => {
                    'text'=>['1'], 'tag' => ["H1"], 'attributes' => {"id" => ["1", "2"]}},
                  'pappy' => {
                    'text'=>['2'], 'tag' => ['K1'], 'attributes' => {"id" => ["x"]}},
                  'granny' => {
                    'text'=>['x'], 'tag' => ['P1'], 'attributes' => {"id" => ["7"], "ip" => ["0"]}}},
                'negative' => {
                  'self' => {
                    'text'=>['1'], 'tag' => ["H1"], 'attributes' => {"id" => ["1"]}},
                  'pappy' => {
                    'text'=>['2'], 'tag' => ['K1'], 'attributes' => {"id" => ["x"]}},
                  'granny' => {
                    'text'=>['x'], 'tag' => ['P1'], 'attributes' => {"id" => ["7"]}}},
                }

    @second = {'options' => {'collection' => false},
                'positive' => {
                  'self' => {
                    'text'=>['1'], 'tag' => ["H1"], 'attributes' => {"id" => ["1"]}},
                  'pappy' => {
                    'text'=>['7'], 'tag' => ['R1'], 'attributes' => {"id" => ["y","z"], "ip" => ["0"]}},
                  'granny' => {
                    'text'=>[], 'tag' => [], 'attributes' => {"id" => []}}},
                'negative' => {
                  'self' => {
                    'text'=>['1'], 'tag' => ["H1"], 'attributes' => {"id" => ["1","2"]}},
                  'pappy' => {
                    'text'=>['7'], 'tag' => ['R1'], 'attributes' => {"id" => ["y"]}},
                  'granny' => {
                    'text'=>[], 'tag' => [], 'attributes' => {"id" => []}}},
                }
    @collection = {"options"=>{"collection"=>false},
                   "positive"=>
                    {"self"=>{"text"=>["1"], "tag"=>["H1"], "attributes"=>{"id"=>["1"]}},
                     "pappy"=>{"text"=>[], "tag"=>[], "attributes"=>{"id"=>[]}},
                     "granny"=>{"text"=>[], "tag"=>[], "attributes"=>{"id"=>[]}}},
                   "negative"=>
                     {"self"=>{"text"=>[], "tag"=>[], "attributes"=>{"id"=>[]}},
                      "pappy"=>{"text"=>["2"], "tag"=>["K1"], "attributes"=>{"id"=>["x"]}},
                      "granny"=>{"text"=>["x"], "tag"=>["P1"], "attributes"=>{"id"=>["7"]}}}}
    @clear = {"options"=>{"collection"=>false},
              "positive"=>
               {"self"=>{"text"=>["1"], "tag"=>["H1"], "attributes"=>{"id"=>["1"]}},
                "pappy"=>{"text"=>[], "tag"=>[], "attributes"=>{"id"=>[], "ip"=>["0"]}},
                "granny"=>{"text"=>[], "tag"=>[], "attributes"=>{"id"=>[]}}},
              "negative"=>
               {"self"=>{"text"=>[], "tag"=>[], "attributes"=>{"id"=>[]}},
                "pappy"=>{"text"=>["2"], "tag"=>["K1"], "attributes"=>{"id"=>["x"]}},
                "granny"=>{"text"=>["x"], "tag"=>["P1"], "attributes"=>{"id"=>["7"]}}}}
    @summa = {"self"=>{"text"=>["1"], "tag"=>["H1"], "attributes"=>{"id"=>["1", "2"]}},
             "pappy"=>{"text"=>["2", "7"], "tag"=>["K1", "R1"], "attributes"=>{"id"=>["x", "y", "z"], "ip"=>["0"]}},
             "granny"=>{"text"=>["x"], "tag"=>["P1"], "attributes"=>{"id"=>["7"], "ip"=>["0"]}}}
    @extra = {"self"=>{"text"=>[], "tag"=>[], "attributes"=>{"id"=>["2"]}},
             "pappy"=>{"text"=>["2"], "tag"=>["K1"], "attributes"=>{"id"=>["x"]}},
             "granny"=>{"text"=>["x"], "tag"=>["P1"], "attributes"=>{"id"=>["7"]}}}

  end

  it 'can do collection correctly' do
    merger = Marta::PageArithmetic::MethodMerger.new(@first, @second)
    expect(merger.do_collection).to eq @collection
  end

  it 'can forget unstable attributes' do
    merger = Marta::PageArithmetic::MethodMerger.new(@first, @second)
    expect(merger.forget_unstable).to eq @clear
  end

  it 'can merge hashes (adding new and killing unstable)' do
    merger = Marta::PageArithmetic::MethodMerger.new(@first, @second)
    result = merger.merge(@first['positive'], @second['positive'])
    expect(result).to eq @clear['positive']
  end

  it 'can summarize hashes (full adding)' do
    merger = Marta::PageArithmetic::MethodMerger.new(@first, @second)
    result = merger.summarize(@first['positive'], @second['positive'])
    expect(result).to eq @summa
  end

  it 'can multiply hashes (leaving only common)' do
    merger = Marta::PageArithmetic::MethodMerger.new(@first, @second)
    result = merger.multiply(@first['positive'], @second['positive'])
    expect(result).to eq @collection['positive']
  end

  it 'can extract hashes (deleting commons)' do
    merger = Marta::PageArithmetic::MethodMerger.new(@first, @second)
    result = merger.extract(@first['positive'], @second['positive'])
    expect(result).to eq @extra
  end
end

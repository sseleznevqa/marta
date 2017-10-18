require 'spec_helper'
require 'pry'

describe Marta do

  before(:each) do
    @one = {"self":{"a": "b", "b": ["c", "1"], "x": "ZZ", "one": "two"},"pappy":{},"granny":{}, "not_pappy": {"a": "j", "b": ["c", "d"], "z":"UU", "k":"0"}}
    @two = {"self":{"a": "b", "b": ["d", "1"], "x": "YY", "uniq": "wow"},"pappy":{},"granny":{}, "not_pappy": {"a": "b", "b": ["x", "d"], "z":"TT", "l": ""}}
    @options1 = {"options" =>{"collection" => true, "granny"=> "XX", "pappy"=> "0", "self"=> "*", "not_granny"=> "XX", "not_self"=> "*"}}
    @options2 = {"options" =>{"collection" => true, "granny"=> "YY", "pappy"=> "0", "self"=> ".", "not_granny"=> "*", "not_self"=> "RR"}}
    @passive1 = [{:self=>{:a=>"b", :b=>["c", "1"], :x=>"ZZ", :one=>"two"},
                :pappy=>{},
                :granny=>{},
                :options=>{},
                :not_pappy=>{:a=>"j", :b=>["c", "d"], :z=>"UU", :k=>"0"}},
                {:self=>{:a=>"b", :b=>["d", "1"], :x=>"YY", :uniq=>"wow"},
                :pappy=>nil,
                :granny=>nil,
                :options=>nil,
                :not_pappy=>{:a=>"b", :b=>["x", "d"], :z=>"TT", :l=>""}}]
  end

  it 'can find common parts of hashes correctly' do
    merger = Marta::PageArithmetic::MethodMerger.new(@one, @two)
    expect(merger.common_of(:self)).to eq ({:a=>"b", :b=>["1"]})
  end

  it 'can make one hash of two by special rule' do
    # We have a visible problem here. We need arrays for attrs policy!
    merger = Marta::PageArithmetic::MethodMerger.new(@one, @two)
    expect(merger.all_of(:self)).to eq ({:a=>"b", :b=>["d", "1"], :x=>"YY", :one=>nil, :uniq=>"wow"})
  end

  it 'can merge element tags' do
    merger = Marta::PageArithmetic::MethodMerger.new(@options1, @options2)
    expect(merger.options_merge).to eq ({"collection"=>true, "self"=>"*", "pappy"=>"0", "not_pappy"=>nil, "granny"=>"*"})
  end


end

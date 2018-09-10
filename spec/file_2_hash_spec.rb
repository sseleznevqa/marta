require 'spec_helper'
require 'pry'

describe Marta::SmartPage do
  before(:all) do
    @full_name = "./spec/test_data_folder/test_pageobjects/Json2Class.json"
    @bad_name = "./spec/test_data_folder/test_pageobjects/Bad.json"
    @fake_name = "./spec/test_data_folder/test_pageobjects/Fake.json"
    @old_version = "./spec/test_data_folder/test_pageobjects/Old.json"
    @old_content = %Q[
      {"meths":
        {"old_version":
          {"options":{"collection":false, "granny":"*", "pappy":"DIV", "self":"SPAN", "not_granny":"GRANNY", "not_self":"DIV", "not_pappy":"FORM"},
        "granny":{"x":"g r","retrieved_by_marta_text":"a n","class":["n","y"]},
        "pappy":{"y":"p a","retrieved_by_marta_text":"p p","class":["y","y"]},
        "self":{"z":"s e","retrieved_by_marta_text":"l f","class":["s","f"]},
        "not_self":{"a":"1 2","retrieved_by_marta_text":"3 4","class":["5","6"]},
        "not_pappy":{"b":"7 8","retrieved_by_marta_text":"9 0","class":["a","b"]},
        "not_granny":{"c":"c d","retrieved_by_marta_text":"e f","class":["too","long"]}
        }},
      "vars":{"new_var":"!"}}
                   ]
    @new_version =
      {"meths"=>
      {"old_version"=>
        {"options"=>{"collection"=>false},
         "positive"=>
          {"self"=>{"text"=>["l f"], "tag"=>["SPAN"], "attributes"=>{"z"=>["s", "e"], "class"=>["s", "f"]}},
           "pappy"=>{"text"=>["p p"], "tag"=>["DIV"], "attributes"=>{"y"=>["p", "a"], "class"=>["y", "y"]}},
           "granny"=>{"text"=>["a n"], "tag"=>[], "attributes"=>{"x"=>["g", "r"], "class"=>["n", "y"]}}},
         "negative"=>
          {"self"=>{"text"=>["3 4"], "tag"=>["DIV"], "attributes"=>{"a"=>["1", "2"], "class"=>["5", "6"]}},
           "pappy"=>{"text"=>["9 0"], "tag"=>["FORM"], "attributes"=>{"b"=>["7", "8"], "class"=>["a", "b"]}},
           "granny"=>{"text"=>["e f"], "tag"=>["GRANNY"], "attributes"=>{"c"=>["c", "d"], "class"=>["too", "long"]}}}}},
     "vars"=>{"new_var"=>"!"}}
  end

  it 'will convert old jsons to new version' do
    File.open(@old_version, "w") do |f|
      f.write(@old_content)
    end
    expect(marta_fire(:file_2_hash, @old_version)).to eq @new_version
  end

  it 'will return nil instead of hash on parsing error' do
    expect(marta_fire(:file_2_hash, @bad_name)).to eq nil
  end

  it 'will return nil instead of hash if json file does not exist' do
    expect(marta_fire(:file_2_hash, @fake_name)).to eq nil
  end

  it 'will return a Hash for given json' do
    expect(marta_fire(:file_2_hash, @full_name).class).to eq Hash
  end
end

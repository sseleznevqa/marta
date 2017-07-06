require 'spec_helper'

describe Marta::SmartPage do
  before(:all) do
    class Mock < Marta::SmartPage
      attr_accessor :a, :b, :c
    end
    @mock = Mock.new("Dummy", ({"vars" => {},"meths" => {}}), false)
    @mock.a = "Hello"
    @mock.b = "World!"
    @mock.c = '#{@b}'
  end

  it 'can process strings like "#{@var}"' do
    expect(@mock.send(:process_string, "\#{@a} \#{@b}")).to eq("Hello World!")
  end

  it 'can process strings like "#{@var}" where @var ="#{@var2}"' do
    expect(@mock.send(:process_string, "\#{@a} \#{@c}")).to eq("Hello World!")
  end

  it 'can process nil strings to ""' do
    expect(@mock.send(:process_string, nil)).to eq("")
  end
end

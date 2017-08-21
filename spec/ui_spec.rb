require 'spec_helper'

describe Marta::SmartPage do
  before(:all) do
    @object = Object.new
    @object.extend(Marta)
  end

  it 'can start dance if module is included' do
    expect(@object.send(:dance_with)).to eq @browser
  end

  it 'can return engine if module is included' do
    expect(@object.send(:engine)).to eq @browser
  end

  it 'can eat missed Constans' do
    dance_with learn: true
    def @object.mars_attacks
      Attack
    end
    expect(@object.mars_attacks).to eq Kernel::Attack
  end
end

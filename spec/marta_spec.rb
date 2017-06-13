require 'spec_helper'

describe Marta do
  it 'has a version number' do
    expect(Marta::VERSION).not_to be nil
  end

  it 'stores browser_instance to engine method' do
    expect(@browser).to eq(marta_fire(:engine))
  end
end

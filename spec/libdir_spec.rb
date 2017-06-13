require 'spec_helper'

describe Marta::SmartPage do
  it 'can find folder with files for injection' do
    expect(File.directory?(marta_fire(:gem_libdir))).to be true
  end
end

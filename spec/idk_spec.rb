require 'spec_helper'

describe Marta::SmartPage do
  context 'I do not know is it really happening... but it is covered ;)' do

    before(:each) do
      module Marta
        module OptionsAndPaths
          class SettingMaster
            @@learn = Hash.new
            @@engine = Hash.new
          end
        end
      end
    end

    after(:each) do
      ENV['LEARN']=nil
    end

    it 'correct learn status when is not in learn and it was never defined' do
      expect(marta_fire(:learn_status)).to be false
    end

    it 'correct learn status when is in learn and it was never defined' do
      ENV['LEARN']='anything'
      expect(marta_fire(:learn_status)).to be true
    end

    it 'creating new chrome when engine was never defined' do
      new_instance = dance_with
      expect(new_instance.class).to eq Watir::Browser
      expect(new_instance != @browser).to be true
    end
  end
end

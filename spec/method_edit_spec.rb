require 'spec_helper'

describe Marta::SmartPage do
  context 'creating correct methods with method edit' do

    before(:all) do
      module Marta
        class SmartPage
          alias umd_saved user_method_dialogs
          def user_method_dialogs(method_name)
            donor_name = './spec/test_data_folder/test_pageobjects/Page_three.json'
            file = File.read(donor_name)
            temp_hash = JSON.parse(file)
            @data['meths'].merge!(temp_hash['meths'])
            @data
          end
        end
      end
      module Marta
        class SmartPage
          alias paed_saved page_edit
          def page_edit(*args)
            #Nothing interesting here
          end
        end
      end
    end
    before(:each) do
      @full_name = "./spec/test_data_folder/test_pageobjects/Json2Class.json"
      dance_with learn: true
      marta_fire(:json_2_class, @full_name, true)
      @class = Json2Class.new
      def @class.marta_magic_finder(*args)
        'Magic'
      end
      def @class.marta_simple_finder(*args)
        'Wand'
      end
    end

    after(:all) do
      dance_with learn: false
      module Marta
        class SmartPage
          alias user_method_dialogs umd_saved
        end
      end

      module Marta
        class SmartPage
          alias page_edit paed_saved
        end
      end
    end

    it 'method edit without exact' do
      expect(@class.send(:method_edit, 'new_method')).to eq 'Magic'
      expect((defined? @class.new_method).nil?).to eq(false)
      expect(@class.new_method).to eq 'Magic'
      expect((defined? @class.new_method_exact).nil?).to eq(false)
      expect(@class.new_method_exact).to eq 'Wand'
    end

    it 'method edit with exact' do
      expect(@class.send(:method_edit, 'more_method_exact')).to eq 'Wand'
      expect((defined? @class.more_method).nil?).to eq(false)
      expect(@class.more_method).to eq 'Magic'
      expect((defined? @class.more_method_exact).nil?).to eq(false)
      expect(@class.more_method_exact).to eq 'Wand'
    end
  end
end

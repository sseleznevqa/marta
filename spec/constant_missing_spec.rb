require 'spec_helper'

describe Marta::SmartPage, :need_browser do
  before (:all) do
    @full_name = "./spec/test_data_folder/test_pageobjects/Attack.json"
    FileUtils.rm_rf(@full_name)
  end

  after(:all) do
    #Reverting monkeypatch :(
    #module Marta
      #class SmartPage
        #alias json_2_class j2c_saved
      #end
    #end
    module Marta
      class SmartPage
        alias page_edit paed_saved
      end
    end
    FileUtils.rm_rf(@full_name)
  end

  context 'when not learning' do
    before(:all) do
      @full_name = "./spec/test_data_folder/test_pageobjects/Json2Class.json"
      marta_fire(:json_2_class, @full_name, false)
      #Monkeypatch!
      module Marta
        class SmartPage
          alias paed_saved page_edit
          def page_edit(*args)
            #Nothing interesting here
          end
        end
      end
      @object = Object.new
      @object.extend(Marta)
      def @object.mars_attacks
        Attack
      end
      def @object.earth_strikes_back
        Json2Class.new.earth_strikes_back
      end
    end

    it 'unknown constant will raise an error ' do
      dance_with learn: false
      expect{@object.mars_attacks}.to raise_error(NameError, "uninitialized constant Attack")
    end

    it 'unknown method will raise an error ' do
      expect{@object.earth_strikes_back}.to raise_error(NoMethodError)
    end
  end

  context 'when in learning' do
    before (:each) do
      #module Marta
        #class SmartPage
          #alias json_2_class j2c_saved
        #end
      #end
      dance_with learn: true
      @full_name = "./spec/test_data_folder/test_pageobjects/Json2Class.json"
      marta_fire(:json_2_class, @full_name, true)
      #Monkeypatch!
      @object = Object.new
      @object.extend(Marta)
      def @object.mars_attacks
        Attack
      end
      def @object.earth_strikes_back
        my_class = Json2Class.new
        def my_class.method_edit(*args)
          'BOOM!'
        end
        my_class.earth_strikes_back
      end
    end

    it 'unknown constant will be passed' do
      expect(@object.mars_attacks).to eq Kernel::Attack
      expect(File.exists?(@full_name)).to be true
    end

    it 'unknown method will be passed ' do
      expect(@object.earth_strikes_back).to eq 'BOOM!'
    end
  end

end

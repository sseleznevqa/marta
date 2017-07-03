require 'marta/options_and_paths'
require 'pry'
module Marta

  # Methods that user can use out of the box in SmartPage
  module PublicMethods

    include OptionsAndPaths

    # User can create pageobject class using SmartPage.new
    def initialize(my_data = nil, my_class_name = nil, will_edit = nil)
      #binding.pry
      @data ||= my_data
      @class_name ||= my_class_name
      @edit_mark ||= will_edit
      if !will_edit.nil?
        build_content my_data
        if will_edit
          page_edit my_class_name, my_data
        end
        # We need optimization here very much!
        build_content my_data
      else
        warn "SmartPage was created without any data. So it will"\
        " not work normally. Unless you know exactly what are you doing."
      end
    end

    # User can define a method for example in a middle of a debug session
    def method_edit(name)
      method_name = correct_name(name)
      exact_name = method_name.to_s + "_exact"
      data = user_method_dialogs(@class_name, method_name, @data)
      define_singleton_method method_name.to_sym do |meth_content=@data['meths'][method_name]|
        marta_magic_finder(meth_content)
      end
      define_singleton_method exact_name.to_sym do |meth_content=@data['meths'][method_name]|
        marta_simple_finder(meth_content)
      end
      public_send name.to_sym
    end

    # User can get engine (normally browser instance or iframe element)
    def engine
      SettingMaster.engine
    end

    # If page has url variable it can be opened like Page.new.open_page
    def open_page(url = nil)
      if url != nil
        engine.goto url
      else
        if @url == nil
          raise ArgumentError, "You should set url to use open_page"
        end
        engine.goto @url
      end
    end

    alias_method :default_method_missing, :method_missing

    # method missing hijacking It should be used only for SmartPage
    def method_missing(method_name, *args, &block)
      if learn_status
        method_edit(method_name)# , *args, &block)
      else
        default_method_missing(method_name, *args, &block)
      end
    end
  end
end

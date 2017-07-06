require 'marta/options_and_paths'
module Marta

  # Methods that user can use out of the box in SmartPage
  module PublicMethods

    include OptionsAndPaths


    #
    # User can create pageobject class using SmartPage.new
    #
    # SmartPage can be created withoud all the data. But in that case
    # it will be pretty useless until values are provided
    #
    # The first argument is a class name. It is a constant like string like
    # "MyClass". All data provided will be stored in MyClass.json
    # Once created that way you can call it like MyClass.new.
    # That argument is totally necessary one
    #
    # The second argument is a marta's special data hash. By default =
    # {"vars"=>{},"meths"=>{}}. You can take an existing json as well.
    # Notice that rocket like syntax is a must here. It will be changed later
    #
    # Third parameter is about to show or not default page creation dialog.
    # So it can be true or false
    def initialize(my_class_name, my_data = ({"vars" => {},"meths" => {}}),
                   will_edit = true)
      @data ||= my_data
      @class_name ||= my_class_name
      @edit_mark ||= will_edit
      build_content my_data
      if will_edit
        page_edit my_class_name, my_data
      end
      # We need optimization here very much!
      build_content my_data
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

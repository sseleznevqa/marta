require 'marta/options_and_paths'
require 'marta/read_write'
module Marta

  #
  # Here Marta is reading json files and precreating pageobject classes
  # which were defined previously
  #
  # Main trick of the Marta is parsing jsons files to classes.
  # For example valid Foo.json file in a valid folder will turn into Foo class.
  # Class content differs when Marta is set to learning mode and when it's not.
  # Class will have methods = watir elements
  # and vars = user defined vars with default values.
  # Class will not accept any arguments for generated methods.
  # The class will have default initialize method, engine method.
  #
  # Also the class can has method_edit method. In theory it can be called like
  # Foo.method_edit('new_method_name').
  # It should define new method even if learn mode is disabled.
  # But I am never using such construction :)
  # In learn mode any unknown method will cause dialog that will ask user about
  # what element should be used.
  #
  # Also for each method foo method foo_exact will be created and vice versa.
  # Method wich ends with exact will use strict element searching scheme.
  module Json2Class

    private

    #
    # To create a special class we are using a special class
    #
    # @note It is believed that no user will use it
    class SmartPageCreator

      include OptionsAndPaths, ReadWrite

      #
      # Main class creation method.
      #
      # SmartPage can be initialized with user data as well
      def self.create(class_name, data, edit)
        c = Class.new(SmartPage) do
          alias_method :old_init, :initialize
          define_method :initialize do |my_data=data, my_class_name=class_name,
                                        will_edit=edit|
            old_init(class_name, my_data, will_edit)
          end
        end
        # We are vanishing previous version of class
        if Kernel.constants.include?(class_name.to_sym)
          Kernel.send(:remove_const, class_name.to_sym)
        end
        # We are declaring our class
        Kernel.const_set class_name, c
      end

      # We are parsing file into a class
      def self.json_2_class(json, edit_enabled = true)
        data = ReaderWriter.file_2_hash(json)
        if !data.nil?
          class_name = File.basename(json, ".*")
          edit_mark = SettingMaster.learn_status and edit_enabled
          create class_name, data, edit_mark
        end
      end

      # Marta is parsing all the files in pageobject folder into classes
      def self.create_all
        if File.directory?(SettingMaster.pageobjects_folder)
          Dir["#{SettingMaster.pageobjects_folder}/*.json"].each do |file_name|
            json_2_class(file_name, true) #true here
          end
        else
          FileUtils::mkdir_p SettingMaster.pageobjects_folder
        end
      end
    end

    def read_folder
      SmartPageCreator.create_all
    end

    def json_2_class(json, edit_enabled = true)
      SmartPageCreator.json_2_class(json, edit_enabled)
    end

    def build_content(data)
      build_methods(data['meths'])
      build_vars(data['vars'])
    end

    def build_methods(methods)
      methods.each_pair do |method_name, content|
        build_method method_name, content
      end
    end

    def build_vars(vars)
      vars.each do |var_name, default_value|
        build_var var_name, default_value
      end
    end

    def build_method(name, content)
      define_singleton_method name.to_sym do
        learn_status ? method_edit(name) : marta_magic_finder(content)
      end
      exact = name + '_exact'
      define_singleton_method exact.to_sym do
        learn_status ? method_edit(exact) : marta_simple_finder(content)
      end
    end

    def build_var(name, content)
      if !self.methods.include?(name.to_sym) and (@data['meths'][name].nil?)
        self.singleton_class.send(:attr_accessor, name.to_sym)
        instance_variable_set("@#{name}", process_string(content))
      else
        if !@data['meths'][name].nil?
          warn "Marta will not create '#{name}' variable for #{self.class}"\
          " since it is already in use by method"
        end
      end
    end

    def correct_name(name)
      if name.to_s.end_with? "_exact"
        method_name = name.to_s[0..-7]
      else
        method_name = name.to_s
      end
      method_name
    end
  end
end

require "marta/version"
require 'marta/public_methods'
require 'marta/options_and_paths'
require 'marta/read_write'
require 'marta/user_values_prework'
require 'marta/dialogs'
require 'marta/classes_creation'
require 'marta/lightning'
require 'marta/injector'
require 'marta/json_2_class'
require 'marta/black_magic'
require 'marta/simple_element_finder'
require 'marta/x_path'
require "watir"
require 'fileutils'
require 'json'

#
# Marta class is providing three simple methods.
#
# const_missing is hijacked. And in a learn mode marta will treat any unknown
# constant as an unknown pageobject and will try to ask about using browser
module Marta

  include OptionsAndPaths, ReadWrite, Json2Class

  class SmartPage

    attr_accessor :data, :class_name, :edit_mark

    include BlackMagic, XPath, SimpleElementFinder, ClassesCreation,
            PublicMethods, Dialogs, Injector, Lightning, OptionsAndPaths,
            Json2Class, ReadWrite, UserValuePrework
  end

  # That is how Marta connected to the world

  # We will ask user about completely new class
  def Object.const_missing(const, *args, &block)
    if !SettingMaster.learn_status
      raise NameError, "#{const} is not defined."
    else
      data, data['vars'], data['meths'] = Hash.new, Hash.new, Hash.new
      SmartPageCreator.json_2_class(ReaderWriter.file_write(const.to_s, data))
    end
  end

  # Marta is returning an engine (it should be a browser instance)
  # Watir::Browser.new(:chrome) by default
  def engine
    SettingMaster.engine
  end

  # dance_with is for creating settings to be used later.
  # Settings can be changed at any time by calling dance with.
  # Read more in the README
  def dance_with(browser: nil, folder: nil, learn: nil, tolerancy: nil)
    SettingMaster.set_engine browser
    SettingMaster.set_folder folder
    SettingMaster.set_learn learn
    SmartPageCreator.create_all
    SettingMaster.set_tolerancy tolerancy
    engine
  end
end

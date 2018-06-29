puts require "watir"
puts require 'fileutils'
puts require 'json'
puts require 'webrick'
puts require 'socket'

puts require "marta/version"
puts require "object"
puts require 'marta/public_methods'
puts require 'marta/options_and_paths'
puts require 'marta/read_write'
puts require 'marta/user_values_prework'
puts require 'marta/dialogs'
puts require 'marta/classes_creation'
puts require 'marta/lightning'
puts require 'marta/injector'
puts require 'marta/json_2_class'
puts require 'marta/black_magic'
puts require 'marta/simple_element_finder'
puts require 'marta/x_path'
puts require 'marta/page_arithmetic'
puts require 'marta/server'




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
            Json2Class, ReadWrite, UserValuePrework, PageArithmetic, Server

    # open_page can create new instance
    def self.open_page(*args)
      page = self.new
      page.open_page(*args)
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
  def dance_with(browser: nil, folder: nil, learn: nil, tolerancy: nil,
                 base_url: nil, cold_timeout: nil, port: nil, clear: nil)
    SettingMaster.clear if clear
    SettingMaster.set_port port
    # We are always turning the server on in order to show Welcome!
    SettingMaster.set_server # server should be before browser
    SettingMaster.set_engine browser # browser should be before learn!
    SettingMaster.set_learn learn
    SettingMaster.set_folder folder
    SettingMaster.set_base_url base_url
    read_folder
    SettingMaster.set_tolerancy tolerancy
    SettingMaster.set_cold_timeout cold_timeout
    engine
  end
end

require 'marta/simple_element_finder'
require 'marta/x_path'
require 'marta/lightning'
require 'marta/injector'
require 'marta/public_methods'
module Marta

  #
  # All many-steps dialogs should be here
  #
  # There is at least one situation when getting info from user is not so simple
  # We need dialogs for cases like that. Now there is only dialog about method
  module Dialogs

    private

    #
    # Dialog operator class
    #
    # @note It is believed that no user will use it
    class MethodSpeaker

      include XPath, Lightning, Injector, PublicMethods

      def initialize(class_name, method_name, data, requestor)
        @class_name = class_name
        @method_name = method_name
        @data = data
        @title = class_name+  '.' + method_name.to_s
        @requestor = requestor
      end

      # Standart question
      def ask(what, title = 'Some title', data = Hash.new)
        inject(what, title, data)
      end

      # Main method. All the dialog logic is here
      def dialog
        while !finished? do
          @attrs = ask_for_elements
          @mass = get_elements_by_attrs
          @styles = mass_highlight_turn @mass
          @result = ask_confirmation
          mass_highlight_turn(@mass, false, @styles)
        end
        if @result == '1'
          standart_meth_merge
        else
          xpath_meth_merge
        end
      end

      # Asking: "What are you looking for?"
      def ask_for_elements
        ask 'element', @title, @data['meths'][@method_name]
      end

      # Creating data to save when it is a basically defined element
      def standart_meth_merge
        temp = temp_hash
        temp['meths'][@method_name] = @attrs
        @data['meths'].merge!(temp['meths'])
        @data
      end

      # Creating data to save when user suggests a custom xpath
      def xpath_meth_merge
        temp = temp_hash
        temp['meths'][@method_name]['options'] = @result
        @data['meths'].merge!(temp['meths'])
        @data
      end

      # Finding out what was selected
      def get_elements_by_attrs
        xpath = XPathFactory.new(@attrs, @requestor).generate_xpath
        engine.elements(xpath: xpath)
      end

      # Asking: "Are you sure?"
      def ask_confirmation
        ask 'element-confirm', @title, @mass.length.to_s
      end

      # Asking: "Provide your xpath"
      def ask_xpath
        ask 'custom-xpath', @title
      end

      #
      # Is dialog finished?
      #
      # JS returning '1' when it's done. That is not good
      # and should be rewrited as soon as possible
      def finished?
        if @result == '1'
          true
        elsif @result == '3'
          @result = ask_xpath
          (@result != '2') ? true : false
        else
          false
        end
      end

      # Forming of an empty hash for storing element info
      def temp_hash
        temp, temp['meths'], temp['meths'][@method_name],
        temp['meths'][@method_name]['options'] = Hash.new, Hash.new, Hash.new,
        Hash.new
        temp
      end
    end

    # Method definition process
    def user_method_dialogs(my_class_name, method_name, data)
      dialog_master = MethodSpeaker.new(my_class_name, method_name, data, self)
      data = dialog_master.dialog
      file_write(my_class_name.to_s, data)
      data
    end
  end
end

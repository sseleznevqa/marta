require 'marta/simple_element_finder'
require 'marta/x_path'
require 'marta/lightning'
require 'marta/injector'
require 'marta/public_methods'
require 'marta/page_arithmetic'
require 'marta/element_information'

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

      include XPath, Lightning, Injector, PublicMethods, SimpleElementFinder,
              PageArithmetic, ElementInformation

      def initialize(method_name, requestor)
        @class_name = requestor.class_name
        @method_name = method_name
        @data = requestor.data
        @title = @class_name+  '.' + method_name.to_s
        @requestor = requestor
        @found = 0
        @attrs = @data['meths'][@method_name]
        @mass = Array.new
      end

      # Standart question
      def ask(what, title = 'Some title', data = Hash.new, vars = Array.new)
        inject(what, title, data, vars)
      end

      # Was something stated by user?
      def attrs_exists?
        if !@attrs.nil?
          @attrs != Hash.new
        else
          false
        end
      end

      # Main method. All the dialog logic is here
      def dialog
        while !finished? do
          if attrs_exists?
            @mass = get_elements_by_attrs
            mass_highlight_turn @mass
          end
          @result = ask_for_elements
          mass_highlight_turn(@mass, false)
          if @result.class == Hash
            attrs_plus_result
          elsif @result != '1'
            xpath_way
          end
        end
        if @result == '1'
          standart_meth_merge
        else
          xpath_meth_merge
        end
      end

      #
      # This method is responsible for collection in two clicks feature
      #
      # If we have two elements of collection this methods returns hash of
      # element without diffs (only the same attributes). As well this method
      # is responsible for adding excluding attributes to collection.
      # Rare case with single element that not has some attribute is not
      # implemented so far. All that party is for collections now.
      def attrs_plus_result
        if !attrs_exists?
          @attrs = @result
        elsif !@result['options']['collection']
          @attrs = @result
        else
          @attrs = make_collection(@attrs, @result)
        end
      end

      # Asking: "What are you looking for?"
      def ask_for_elements
        answer = ask 'element', "Found #{@found} elements for #{@title}", @attrs
        return answer.class == Hash ? answer_to_hash(answer) : answer
      end

      # Creating new fashioned hash out of data
      def answer_to_hash(answer)
        result = method_structure
        result['options']['collection'] =  answer['collection']
        what = answer['exclude'] ? 'negative' : 'positive'
        result[what] = get_attributes(answer['element'])
        result
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
        temp['meths'][@method_name]['options'] = @attrs['options']
        @data['meths'].merge!(temp['meths'])
        @data
      end

      # Finding out what was selected
      def get_elements_by_attrs
        if @attrs['options']['xpath'].nil?
          xpath = XPathFactory.new(@attrs, @requestor).generate_xpath
        else
          xpath = @attrs['options']['xpath']
        end
        result = engine.elements(xpath: xpath)
        @found = result.length
        result
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
        if @result == '1' or @result == '4'
          true
        else
          false
        end
      end

      # When user selects xpath way. Marta is doing some work before finish
      def xpath_way
        @result = ask_xpath
        if @result != '2'
          @attrs = Hash.new
          @attrs['options'] = @result
          @mass = get_elements_by_attrs
          mass_highlight_turn @mass
          @result = ask_confirmation
          mass_highlight_turn(@mass, false)
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
    def user_method_dialogs(method_name)
      dialog_master = MethodSpeaker.new(method_name, self)
      data = dialog_master.dialog
      data['meths'][method_name] =
                    dynamise_method(data['vars'], data['meths'][method_name])
      file_write(self.class_name.to_s, data)
      data
    end

    # Massive gsub for attribute
    def dynamise(variable_name, what)
      what.each do |entry|
        entry.each do |value|
          value.gsub!(self.instance_variable_get("@#{variable_name}"),
             '#{@' + variable_name + '}')
        end
      end
    end

    # Marta will search for page variables in attributes of element in order
    # to create dynamic element by itself. It must be splited. And moved.
    def dynamise_method(vars, method)
      vars.each_pair do |variable_name, variable|
        if variable_name == 'text'
          dynamise 'text', [method['positive']['self']['text'],
                            method['positive']['pappy']['text'],
                            method['positive']['granny']['text'],
                            method['negative']['self']['text'],
                            method['negative']['pappy']['text'],
                            method['negative']['granny']['text']]
        else
          [method['positive'], method['negative']].each do |method|
            method.each_pair do |level, content|
              content['attributes'].each_pair do |attribute_name, values|
                if variable_name.include?(attribute_name)
                  dynamise variable_name, [values]
                end
              end
            end
          end
        end
      end
      method
    end
  end
end

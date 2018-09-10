require 'marta/x_path'
require 'marta/simple_element_finder'
require 'marta/options_and_paths'
require 'marta/element_information'
require 'marta/page_arithmetic'
require 'marta/read_write'

module Marta

  #
  # Black magic is responsible for lost element searching
  #
  # When it is impossible to find element as is we have a special algorithm.
  # It is suggesting that one part of xpath (tag or attribute) is wrong.
  # So it is checking all the possible combination of xpath with excluding of each
  # xpath part one by one.
  # When there is no success it is trying without two parts
  # It repeats everything until it finds something or number of variants is
  # becoming larger than tolerancy value
  module BlackMagic

    include XPath, SimpleElementFinder, OptionsAndPaths

    private

    #
    # Element searching class.
    #
    # @note It is believed that no user will use it
    class MagicFinder < BasicFinder

      include OptionsAndPaths, PageArithmetic, ElementInformation, ReadWrite

      def initialize(meth, tolerancy, name, requestor)
        @tolerancy = tolerancy
        @engine = requestor.engine
        @name = name
        @requestor = requestor
        super(meth, requestor)
      end

      # We can prefind an element and wait for it.
      def prefind_with_waiting
        begin
          prefind.wait_until_present(timeout: SettingMaster.cold_timeout)
        rescue
          # found nothing
          prefind
        end
      end

      def return_collection
        result = prefind_collection
        to_save = @meth
        result.each do |item|
          meth_data = method_structure true
          meth_data['positive'] = get_attributes item, @requestor
          to_save = forget_unstable(to_save, meth_data)
        end
        file_name  = @requestor.instance_variable_get("@class_name").to_s
        file_data = @requestor.instance_variable_get("@data")
        file_data['meths'][@name] = to_save
        file_write(file_name, file_data)
        result
      end

      def return_element
        result = prefind
        meth_data = method_structure
        meth_data['positive'] = get_attributes result, @requestor
        to_save = forget_unstable(@meth, meth_data)
        file_name  = @requestor.instance_variable_get("@class_name").to_s
        file_data = @requestor.instance_variable_get("@data")
        file_data['meths'][@name] = to_save
        file_write(file_name, file_data)
        subtype_of prefind
      end

      # Main method. It finds an element
      def find
        if !forced_xpath?
          element = prefind_with_waiting
          warn_and_search element
        end
        if collection?
          return_collection
        else
          return_element
        end
      end

      # Marta is producing warning when element was not found normally
      def warn_and_search(element)
        if !element.exists?
          warn "ATTENTION: Element "\
               "#{@requestor.instance_variable_get("@class_name")}.#{@name}"\
               " was not found by locator = #{@xpath}."
          warn "And Marta uses a black"\
               " magic to find it. If she finds something"\
               " Marta redefines it without warning."
          actual_searching(element)
        end
      end

      # Marta can form special xpath guess for element finding attempt
      def form_complex_xpath(unknowns, granny=true, pappy=true)
        xpath_factory = XPathFactory.new(@meth, @requestor)
        xpath_factory.granny = granny
        xpath_factory.pappy = pappy
        if xpath_factory.array_of_hashes.count <= unknowns
          raise "Marta did her best. But she found nothing"
        else
          xpath_factory.generate_xpaths(unknowns, @tolerancy)
        end
      end

      # We should manage granny, pappy and i values for additional steps
      def granny_pappy_manage(granny, pappy)
        if !(granny or pappy)
          raise "Marta did her best. But she found nothing"
        end
        if (granny and pappy) or (granny and !pappy)
          granny = false
        else
          granny, pappy = true, false
        end
        return granny, pappy
      end

      # We are  forming arrays of candidates
      def candidates_arrays_creation(array_of_xpaths)
        array_of_elements, array_of_els_xpaths = Array.new, Array.new
        something = nil
        array_of_xpaths.each do |xpath|
          something = @engine.elements(xpath: xpath)
          if something.to_a.length > 0
            array_of_elements += something.to_a
            something.to_a.length.times {array_of_els_xpaths.push xpath}
          end
        end
        return array_of_elements, array_of_els_xpaths
      end

      # Selecting the most common element in the array.
      def get_search_result(result, array_of_elements, array_of_els_xpaths)
        something = result
        if array_of_elements.size > 0
          inputs = get_result_inputs(array_of_elements)
          most_uniq_xpath_by_inputs(array_of_els_xpaths, inputs)
          array_of_elements[array_of_els_xpaths.index(@xpath)]
        else
          something
        end
      end

      # Getting indexes of the most common element in the array of suggested
      # elements
      def get_result_inputs(array_of_elements)
        result = array_of_elements.group_by(&:itself).
                 values.max_by(&:size).first
        array_of_elements.each_index.
                                select{|i| array_of_elements[i] == result}
      end

      # Getting the most specific xpath for the most common element in order
      # to locate it only
      def most_uniq_xpath_by_inputs(array_of_els_xpaths, inputs)
        xpaths = Array.new
        array_of_els_xpaths.
               each_with_index{|e, i| xpaths.push e if inputs.include?(i)}
        @xpath = xpaths[0]
        xpaths.each do |x|
          current_count = array_of_els_xpaths.count(x)
          proposed_count = array_of_els_xpaths.count(@xpath)
          @xpath = x if current_count < proposed_count
        end
        @xpath
      end

      # The core of Black Magic Algorithm
      def actual_searching(result)
        granny, pappy, i = true, true, 1
        while !result.exists?
          array_of_xpaths = form_complex_xpath(i, granny, pappy)
          if XPathFactory.new(@meth, @requestor).analyze(i, @tolerancy)[0] < i
            # One more step.
            # We will try to exclude grandparent element data at first.
            # Then we will try to exclude parent.
            # Finally we will try to exclude all the parents.
            # If they are already excluded and Marta is out of tolerancy...
            granny, pappy, i = granny_pappy_manage(granny, pappy) + [1]
            array_of_xpaths = form_complex_xpath(i, granny, pappy)
          end
          array_of_elements,
            array_of_els_xpaths = candidates_arrays_creation(array_of_xpaths)
          i += 1
          result =
              get_search_result(result, array_of_elements, array_of_els_xpaths)
        end
        return result
      end
    end

    # Marta can find something when data is incorrect (by Black magick)
    def marta_magic_finder(meth, name = "unknown")
      finder = MagicFinder.new(meth, tolerancy_value, name, self)
      finder.find
    end
  end
end

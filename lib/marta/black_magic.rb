require 'marta/x_path'
require 'marta/simple_element_finder'
require 'marta/options_and_paths'

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

      include OptionsAndPaths

      def initialize(meth, tolerancy, requestor)
        @tolerancy = tolerancy
        @engine = requestor.engine
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

      # Main method. It finds an element
      def find
        if !forced_xpath?
          element = prefind_with_waiting
          warn_and_search element
        end
        super
      end

      # Marta is producing warning when element was not found normally
      def warn_and_search(element)
        if !element.exists?
          warn "Element #{@xpath} was not found. And Marta uses a black"\
               " magic to find it. Redefine it as soon as possible"
          actual_searching(element)
        end
      end

      # Marta can form special xpath guess for element finding attempt
      def form_complex_xpath(unknowns, granny=true, pappy=true)
        xpath_factory = XPathFactory.new(@meth, @requestor)
        xpath_factory.granny = granny
        xpath_factory.pappy = pappy
        if xpath_factory.create_xpath.count <= unknowns
          raise "Marta did her best. But she found nothing"
        else
          xpath_factory.generate_xpaths(unknowns)
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
          something = @engine.element(xpath: xpath)
          if something.exists?
            array_of_elements.push something
            array_of_els_xpaths.push xpath
          end
        end
        return array_of_elements, array_of_els_xpaths
      end

      # Selecting the most common element in the array.
      def get_search_result(result, array_of_elements, array_of_els_xpaths)
        something = result
        if array_of_elements.size > 0
          result = array_of_elements.group_by(&:itself).
                   values.max_by(&:size).first
        else
          result = nil
        end
        if result != nil
          @xpath = array_of_els_xpaths[array_of_elements.index(result)]
        else
          result = something
        end
        return result
      end

      # The core of Black Magic Algorithm
      def actual_searching(result)
        granny, pappy, i = true, true, 1
        while !result.exists?
          array_of_xpaths = form_complex_xpath(i, granny, pappy)
          if array_of_xpaths.count >= @tolerancy
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
    def marta_magic_finder(meth)
      finder = MagicFinder.new(meth, tolerancy_value, self)
      finder.find
    end
  end
end

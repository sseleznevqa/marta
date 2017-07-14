require 'marta/x_path'

module Marta

  # Marta uses simple algorithm for element location when possible
  # Or when method has _exact ending
  module SimpleElementFinder

    private

    #
    # That class is about simle element location strategy
    #
    # @note It is believed that no user will use it
    # The main idea is not to find an element but to find an xpath that leads
    # to a valid element.
    class BasicFinder

      include XPath

      def initialize(meth, requestor)
        @requestor = requestor
        @meth = meth
        @xpath = xpath_by_meth
        @engine = requestor.engine
      end

      # Maybe our element is defined as a collection?
      def collection?
        @meth['options']['collection']
      end

      # Maybe our element has user provided xpath?
      def forced_xpath?
        !@meth['options']['xpath'].nil?
      end

      # Getting an xpath
      def xpath_by_meth
        if forced_xpath?
          @meth['options']['xpath']
        else
          XPathFactory.new(@meth, @requestor).generate_xpath
        end
      end

      # element prefinding
      def prefind
        @engine.element(xpath: @xpath)
      end

      # collection prefinding
      def prefind_collection
        @engine.elements(xpath: @xpath)
      end

      # Transforming an element to a subtype
      def subtype_of(element)
        element = @engine.element(xpath: @xpath).to_subtype
        #https://github.com/watir/watir/issues/537
        if element.class == Watir::IFrame
          element = @engine.iframe(xpath: @xpath)
        end
        element
      end

      # Main logic. We are returning a prefinded collection
      # or subtyped prefind
      def find
        if collection?
          prefind_collection
        else
          subtype_of prefind
        end
      end
    end

    # We can simply find something
    def marta_simple_finder(meth)
      finder = BasicFinder.new(meth, self)
      finder.find
    end
  end
end

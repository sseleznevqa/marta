require 'marta/user_values_prework'

module Marta

  # That module is about creating xpaths for element searching
  module XPath

    private

    #
    # Here we are creating xpath including arrays of xpaths with one-two-...-x
    # parts that are not known
    #
    # @note It is believed that no user will use it
    # All xpaths for Marta are constructed out of three parts:
    # granny, pappy, and self. Where self is a xpath for DOM element itself,
    # pappy is for father element, granny is for grandfather.
    # For example //DIV/SPAN/INPUT: //DIV = granny, /SPAN = pappy,
    # /INPUT = self.
    #
    # We are generating special arrays of hashes at first for each part.
    # And then we are constructing final xpaths
    class XPathFactory

      include UserValuePrework

      attr_accessor :granny, :pappy
      def initialize(meth, requestor)
        @meth = meth
        @granny = @pappy = true
        @requestor = requestor
      end

      # Getting a part (by data or empty=any)
      def get_xpaths(todo, what)
        if todo
          result = []
          if !@meth[what].nil?
            result = form_array_hash(@meth['options'][what], @meth[what])
          end
          if !@meth['not_' + what].nil?
            result = result + form_array_hash(@meth['options']['not_' + what],
                                              @meth['not_' + what], true)
          end
          result
        else
          [make_hash("//", "//"), make_hash("*", "*")]
        end
      end

      # Creating the granny part of xpath
      def create_granny
        # We are suggesting that granny is not a very first element
        result = get_xpaths(@granny, 'granny')
        result[0] = make_hash("//", "//")
        result
      end

      # Creating the pappy part of xpath
      def create_pappy
        get_xpaths(@pappy, 'pappy')
      end

      # Creating self part of xpath
      def create_self
        get_xpaths(true, 'self')
      end

      # Full array of hashes to transform into xpath
      def create_xpath
        result_array = Array.new
        result_array = create_granny + create_pappy + create_self
      end

      # Creating hash arrays from base array
      def form_variants(depth)
        work_array = [create_xpath]
        depth.times do
          temp_array = Array.new
          work_array.each do |one_array|
            temp_array = temp_array + form_xpaths_from_array(one_array)
          end
          work_array = (work_array + temp_array).uniq
        end
        work_array
      end

      #
      # Creating an array of xpaths
      #
      # When depth is 1 we will create out of xpath = //DIV/SPAN/INPUT
      # variants = //*/SPAN/INPUT, //DIV//SPAN/INPUT, //DIV/*/INPUT,
      # //DIV/SPAN//INPUT, //DIV/SPAN/* and //DIV/SPAN/INPUT as well
      def generate_xpaths(depth)
        result_array = Array.new
        form_variants(depth).each do |variant|
          xpath = String.new
          variant.each do |part|
            xpath = xpath + part[:full]
          end
          result_array.push process_string(xpath, @requestor)
        end
        result_array
      end

      # Special method to get the single xpath only. Without unknowns
      def generate_xpath
        generate_xpaths(0).join
      end

      # Getting array of hashes from the raw data
      def form_xpaths_from_array(array)
        result_array = Array.new
        array.each_with_index do |item, index|
          temp_array = Array.new
          array.each_with_index do |item2, index2|
            if index == index2
              temp_array.push make_hash(item2[:empty],item2[:empty])
            else
              temp_array.push make_hash(item2[:full],item2[:empty])
            end
          end
          result_array = result_array.push temp_array
        end
        result_array
      end

      # Creating a small part of array hash for tag
      def form_array_hash_for_tag(tag, negative)
        result_array = Array.new
        if negative
          if !tag.nil? and tag != ""
            result_array.push make_hash("[not(self::#{tag})]", "")
          end
        else
          result_array.push make_hash("/", "//")
          result_array.push make_hash(tag, "*")
        end
        result_array
      end

      # Creating an array hash
      def form_array_hash(tag, attrs, negative = false)
        result_array = form_array_hash_for_tag(tag, negative)
        attrs.each_pair do |attribute, value|
          if attribute.include?('class')
            result_array = result_array +
                        form_array_hash_for_class(attribute, value, negative)
          else
            result_array.push form_hash_for_attribute(attribute,
                                                      value,
                                                      negative)
          end
        end
        result_array
      end

      # Creating a small part of array hash for attribute
      def form_hash_for_attribute(attribute, value, negative)
        result_array = Array.new
        not_start, not_end = get_nots_frames(negative)
        if attribute == 'retrieved_by_marta_text'
          make_hash("[#{not_start}contains(text(),'#{value}')#{not_end}]", "")
        else
          make_hash("[#{not_start}@#{attribute}='#{value}'#{not_end}]", "")
        end
      end

      def get_nots_frames (negative)
        return negative ? ["not(", ")"] : ["", ""]
      end

      # Creating a small part of array hash for attribute contains 'class'
      def form_array_hash_for_class(attribute, value, negative)
        result_array = Array.new
        not_start, not_end = get_nots_frames(negative)
        value.each do |value_part|
          if value_part.gsub(' ','') != ''
            result_array.push make_hash("[#{not_start}contains(@#{attribute},"\
                                        "'#{value_part}')#{not_end}]", "")
          end
        end
        result_array
      end

      # Creating the smallest possible part of array hash
      def make_hash(full, empty)
        {full: "#{full}", empty: "#{empty}"}
      end
    end
  end
end

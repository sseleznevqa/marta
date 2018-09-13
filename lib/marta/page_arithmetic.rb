require 'marta/element_information'
module Marta

  #
  # This is for merging of Smartpages and elements.
  #
  # There is a need too form a right collection out of two elements
  # Page merging will live here as well.
  module PageArithmetic

    private

    #
    # This class is used to merge hashes of elements\methods
    #
    # @note It is believed that no user will use it
    # Now it has only one way to merge hashes
    # This method is getting common only of two methods in order to generate a
    # correct hash for collection element.
    class MethodMerger

      include ElementInformation

      # Class is taking two hashes. Sometimes order is valuable
      def initialize(main_hash, second_hash)
        @main_hash = main_hash
        @second_hash = second_hash
      end

      # Main method for adding two elements into a large-wide collection
      def do_collection
        result = method_structure
        # Everything is simple for now with options)
        result['options'] = @main_hash['options']
        # If we are adding to collection
        if @second_hash['positive']['self']['tag'] != []
          result['positive'] = multiply(@main_hash['positive'],
                                        @second_hash['positive'])
          result['negative'] = extract(@main_hash['negative'],
                                       @second_hash['positive'])
        else # If we are excluding from collection
          result['positive'] = @main_hash['positive']
          uniqs = extract(@second_hash['negative'], @main_hash['positive'])
          result['negative'] = summarize(uniqs, @main_hash['negative'])
        end
        result
      end

      # When black magic finds something
      # she's not trusting dynamic attribute anymore. So she's forgetting
      # unstable attributes and remembering stable and new ones
      def forget_unstable
        result = method_structure
        result['options'] = @main_hash['options']
        result['positive'] = merge(@main_hash['positive'],
                                      @second_hash['positive'])
        result['negative'] = extract(@main_hash['negative'],
                                      @second_hash['positive'])
        result
      end

      # Recursive operations with method.
      def do_arithmetic(first, second, what)
        what == '+' ? result = second : result = Hash.new
        first.each_pair do |key, value|
          if value.is_a? Hash
            result[key] = do_arithmetic(first[key], second[key], what)
          elsif !second[key].nil?
            if what == '+'
              result[key] = (first[key] + second[key]).uniq
            elsif what == '&'
              result[key] = first[key] & second[key]
            elsif what == '-'
              result[key] = first[key] - second[key]
            elsif what == '*'
              if (second[key] != [])
                result[key] = first[key] & second[key]
              end
            end
          end
          if (second[key] == [] or second[key].nil?) and
                ((what == '+') or (what == '*'))
            result[key] = first[key]
          end
        end
        result
      end

      # That is not a real merge. We are leaving everything that is the same
      # or new and deleting everyting that is not the same
      #
      # Idea:
      # merge({a:[1],b:[2],c:[3]},{a:[1],b:[2,3]}) #=> {a:[1],b:[2],c:[3]}
      def merge(first, second)
        do_arithmetic(second, first, '*')
      end

      # Simple adding everyting to everything
      #
      # Idea:
      # summarize({a:[1],c:[4]},{a:[2],b:[3]}) #=> {a:[1,2],b:[3],c:[4]}
      def summarize(first, second)
        do_arithmetic(second, do_arithmetic(first, second, '+'), '+')
      end

      # That will leave only the same options in the result
      #
      # Idea:
      # multiply({a:[1,2],b:[2],c:[5]},{a:[1,3],b:[4],d:[0]}) #=> {a:[1],b:[2]}
      def multiply(first, second)
        do_arithmetic(first, second, '&')
      end

      # That will take out of the result all options of second
      #
      # Idea
      # extract({a:[1,2],b:[2],c:[5]},{a:[2],c:[5],d:[0]}) #=> {a:[1],b:[2]}
      def extract(first, second)
        do_arithmetic(first, second, '-')
      end
    end

    # Form collection out of two element hashes
    def make_collection(one, two)
      merger = MethodMerger.new(one, two)
      merger.do_collection
    end

    # Forgetting unstable attributes leaving the same ones and new ones
    def forget_unstable(old_one, new_one)
      merger = MethodMerger.new(old_one, new_one)
      merger.forget_unstable
    end
  end
end

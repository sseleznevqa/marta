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

      # We are trying to understand here how much work should we do in order
      # to generate all possible xpaths variants.
      #
      # depth is suggested amount of unstable xpath parts
      # limit is the maximum amount of xpaths that we want to generate
      # If we can try all the combinations of xpaths with considering
      # depth elements unstable withou reaching the limit of tries,
      # method will return that depth and precreated array_of_hashes
      # If limit will be reached on creation of all xpaths, method
      # is returning last acceptable depth and array_of_hashes
      def analyze(depth, limit)
        hashes = array_of_hashes
        count = 1
        real_depth = 0
        variativity = 0
        hashes.each do |hash|
          variativity += (hash[:empty] - hash[:full]).count
        end
        depth.times do
          count = count * variativity
          if count < limit
            real_depth += 1
          end
        end
        return real_depth, hashes
      end

      # Generating not more than limit random xpaths variants considering
      # that depth parts of xpath are unstable
      def monte_carlo(hashes, depth, limit)
        xpaths = Array.new
        while xpaths.count < limit do
          mask = Array.new hashes.count, :full
          depth.times do
            mask[rand(mask.count)] = :empty
          end
          final_array = Array.new
          hashes.each_with_index do |hash, index|
            final_array.push(hash[mask[index]].sample)
          end
          xpaths.push final_array.join
          xpaths
        end
        xpaths
      end

      # We are generating masks like [:empty,:full,:full,:empty]
      # They are used for more understandable logic of looping xpaths variants
      # In fact they are lists with all the combinations of
      # switches :full\:empty. Where the length of switches is the same as
      # length of xpath parts. And amount of :empty switches is depth
      def get_masks(masks, depth)
        result = Array.new
        masks.each do |mask|
          result.push mask
          for i in 0..mask.count-1
            result.push(mask.map { |e| e.dup })
            result.last[i] = :empty
          end
        end
        if depth-1 == 0
          result
        else
          get_masks(result, depth-1)
        end
      end

      # We are forming xpath strings by masks and hashes with data
      def xpaths_by_mask(mask, hashes)
        xpaths = Array.new
        final_array = [[]]
        hashes.each_with_index do |hash, index|
          hash[mask[index]].each_with_index do |hash_value, empty_index|
            if empty_index == 0
              final_array.each do |final_array_item|
                final_array_item.push(hash_value)
              end
            else
              alternative_final_array = []
              final_array.each do |final_array_item|
                alternative_final_array.push final_array_item.dup
              end
              alternative_final_array.each do |a_final_array_item|
                a_final_array_item[-1] = hash_value
              end
              final_array = final_array + alternative_final_array
            end
          end
        end
        final_array.each do |final_array_item|
          xpaths.push final_array_item.join
        end
        xpaths
      end

      # Full logic of xpath generating
      # We are understanding can we find all the possible xpath variations
      # We are creating all possible masks (arrays of switches) one by one
      # If we know that we cannot find all variants we are generating some
      # by more random algorithm
      def generate_xpaths(depth, limit = 100000)
        xpaths = Array.new
        real_depth, hashes = analyze(depth, limit)
        masks = get_masks([Array.new(hashes.count, :full)], real_depth)
        masks.each do |mask|
          xpaths = xpaths + xpaths_by_mask(mask, hashes)
        end
        if real_depth != depth
          xpaths = xpaths + monte_carlo(hashes, depth, limit)
        end
        xpaths.uniq.map {|xpath| process_string(xpath, @requestor)}
      end

      # We can generate straight xpath by all known data
      def generate_xpath
        result = ''
        array_of_hashes.each do |hash|
          result = result + hash[:full][0]
        end
        process_string result, @requestor
      end

      # We are parsing positive part of element data to array of hashes
      def positive_part_of_array_of_hashes(what)
        result = Array.new
        result.push make_hash(@meth['positive'][what]['tag'] != [] ? @meth['positive'][what]['tag'][0] : '*', '*')
        if (@meth['positive'][what]['text'] != []) and (@meth['positive'][what]['text'] != [''])
          result.push make_hash("[contains(text(),'#{@meth['positive'][what]['text'][0]}')]")
        end
        @meth['positive'][what]['attributes'].each_pair do |attribute, values|
          if (values != []) and (values != ['']) and !values.nil?
            values.each do |value|
              result.push make_hash("[contains(@#{attribute},'#{value}')]",
                                    ["[@*[contains(.,'#{value}')]]", ""])
            end
          end
        end
        result
      end

      # We are parsing negative part of element data to array of hashes
      def negative_part_of_array_of_hashes(what)
        result = Array.new
        @meth['negative'][what]['tag'].each do |not_tag|
          result.push make_hash("[not(self::#{not_tag})]", '')
        end
        @meth['negative'][what]['text'].each do |not_text|
          result.push make_hash("[not(contains(text(),'#{not_text}'))]", '')
        end
        @meth['negative'][what]['attributes'].each_pair do |attribute, values|
          if (values != []) and (values != ['']) and !values.nil?
            values.each do |value|
              result.push make_hash("[not(contains(@#{attribute},'#{value}'))]")
            end
          end
        end
        result
      end

      # We are parsing stored element data (tag, text and attributes)
      # into the array of hashes
      #
      # Output looks like:
      # [{full:["//"],empty["//"]},
      # {full:["H1"],empty["*"]},
      # {full:["[@id='x']"],empty["", "[@*[contains(.,'x')]]"]}]
      def array_of_hashes
        result = Array.new
        result.push make_hash('//', '//')
        if @granny
          result = result +
                   positive_part_of_array_of_hashes('granny') +
                   negative_part_of_array_of_hashes('granny')
          result.push make_hash('/', '//')
        end
        if @pappy
          result = result +
                   positive_part_of_array_of_hashes('pappy') +
                   negative_part_of_array_of_hashes('pappy')
          result.push make_hash('/', '//')
        end
        result = result +
                 positive_part_of_array_of_hashes('self') +
                 negative_part_of_array_of_hashes('self')
        result
      end

      # Creating the smallest possible part of array hash
      def make_hash(full, empty = '')
        {full: [full], empty: empty.class != Array ? [empty] : empty}
      end
    end
  end
end

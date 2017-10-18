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
    # correct hash for collection element. Methods of the class are pretty
    # esoteric. Refactoring is a must here.
    class MethodMerger

      # Class is taking two hashes. Sometimes order is valuable
      def initialize(main_hash, second_hash)
        @main_hash = main_hash
        @second_hash = second_hash
      end

      POSITIVE = ['self', 'pappy', 'granny']
      NEGATIVE = ['not_self', 'not_pappy', 'not_granny']

      # Main method for adding two elements into a large-wide collection
      def do_collection
        result = Hash.new
        result['options'] = options_merge
        NEGATIVE.each do |key|
          result[key] = all_of key
        end
        POSITIVE.each do |key|
          result[key], result["not_#{key}"] =
                      passive_exclude(common_of(key), result["not_#{key}"])
        end
        result
      end

      # The most esoteric part of merging elements into collection
      # Now we are loosing nots tags if they are not good for us
      # As well we are loosing positive tags by merging them into alltags
      # symbol == *. The way out is to use arrays for tags.
      def options_merge
        temp = Hash.new
        temp['collection'] = @main_hash['options']['collection']
        POSITIVE.each do |key|
          value = @main_hash['options'][key]
          main_negative = @main_hash['options']["not_#{key}"]
          second_negative = @second_hash['options']["not_#{key}"]
          if (@second_hash['options'][key] == value) or
             ((@second_hash['options'][key].nil?) and (!value.nil?))
            temp[key] = value
          else
            temp[key] = "*"
          end
          if (second_negative != temp[key]) and
               ((second_negative == main_negative) or
                 (main_negative.nil?))
                   temp["not_#{key}"] = second_negative
          end
        end
        temp
      end

      # This method will leave only common elements of both hashes
      def common_of(what)
        temp = Hash.new
        first, second = @main_hash[what], @second_hash[what]
        if !first.nil? and !second.nil?
          first.each_pair do |key, value|
            if second[key] == value
              temp[key] = value
            elsif second[key].class == Array and value.class == Array
              temp[key] = value & second[key]
            end
          end
        else
          temp = first
        end
        temp
      end

      # This method will leave all the elements of hashes. But if one attribute
      # is presented in both. Method will use the one from the main.
      # When it will be possible to use arrays for tags and attributes this
      # logic will be changed
      def all_of(what)
        temp = Hash.new
        first, second = @main_hash[what], @second_hash[what]
        if !first.nil?
          temp = first
        end
        if !second.nil? and !temp.nil?
          second.each_pair do |key, value|
            if (temp[key].nil?) or (temp[key] != value)
              temp[key] = value
            elsif (temp[key].class == Array) and (value.class == Array)
              temp[key] = (value + temp[key]).uniq
            end
          end
          if !first.nil?
            first.each_pair do |key, value|
              if second[key].nil? and !value.nil?
                temp[key] = nil
              end
            end
          end
        else
          temp = second
        end
        temp
      end

      # That is about excluding only attributes that are not presented as
      # positives.
      def passive_exclude(main, passive)
        temp = main
        not_temp = passive
        if !passive.nil?
          passive.each_pair do |key, value|
            if !main[key].nil?
              if main[key] == value
                not_temp[key] = value.class == Array ? []:nil
              elsif (value.class == Array) and (main[key].class == Array)
                not_temp[key] = value - main[key]
              end
            end
          end
        end
        return temp, not_temp
      end
    end

    # Form collection out of two element hashes
    def make_collection(one, two)
      merger = MethodMerger.new(one, two)
      merger.do_collection
    end
  end
end

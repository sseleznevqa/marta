module Marta

  # Marta can parse strings like "hello #{value}"
  module UserValuePrework

    private

    # Marta can parse strings like "hello #{value}"
    def process_string(str='', requestor = self)
      position1 = 0
      # Not pretty. When you will see it again rewrite it
      while (position1 != nil) and (str != nil) do
        position1, position2 = str.index("\#{@"), str.index("}")
        if position1 != nil
          first_part = str[0, position1]
          var_part = str[position1 + 2..position2 - 1]
          last_part = str[position2 + 1..-1]
          str = first_part +
                requestor.instance_variable_get(var_part).to_s +
                last_part
        end
      end
      str.nil? ? '' : str
    end
  end
end

module Marta

  # Marta can parse strings like "hello #{value}"
  module UserValuePrework

    private

    # Marta can parse strings like "hello #{value}"
    def process_string(str='', requestor = self)
      str ||= ""
      n = nil
      while str != n
        str = n if !n.nil?
        thevar = str.match(/\#{@+[^\#{@]*}/).to_s
        if thevar != ""
          value = requestor.instance_variable_get thevar.match(/@.*[^}]/).to_s
          n = str.gsub(thevar, value)
        else
          n = str
        end
      end
      str
    end
  end
end

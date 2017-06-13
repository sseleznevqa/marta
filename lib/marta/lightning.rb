module Marta

  # Marta can highlight or unhighlight elements when her styles are injected.
  module Lightning

    private

    # We can highlight an element
    def highlight(element)
      orig_style = element.attribute_value("style")
      engine.execute_script("arguments[0].setAttribute(arguments[1],"\
                            " arguments[2])", element, "style",
                            "animation: marta_found 6s infinite;")
      orig_style
    end

    # We can unhighlight an element
    def unhighlight(element, style)
      engine.execute_script("arguments[0].setAttribute(arguments[1],"\
                            " arguments[2])", element, "style", style)
    end

    # We can highlight\unhighlight tons of elements at once
    def mass_highlight_turn(mass, turn_on = true, styles = nil)
      result = Array.new
      mass.each_with_index do |element, i|
        if turn_on
          result[i] = highlight(element)
        else
          unhighlight(element, styles[i])
        end
      end
      result
    end
  end
end

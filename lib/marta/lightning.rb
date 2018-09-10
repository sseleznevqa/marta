module Marta

  # Marta can highlight or unhighlight elements when her styles are injected.
  module Lightning

    private

    # We can highlight an element
    def highlight(element)
      if is_here?(element)
        engine.execute_script("arguments[0].setAttribute"\
                            "('martaclass','foundbymarta')", element)
      end
    end

    # We can unhighlight an element
    def unhighlight(element)
      if is_here?(element)
        engine.execute_script("arguments[0].removeAttribute('martaclass')",
                              element)
      end
    end

    # Method to understand that something shouldn't be highlighted
    def is_here?(element)
      element.exists?
    rescue
      false
    end

    # We can highlight\unhighlight tons of elements at once
    def mass_highlight_turn(mass, turn_on = true)
      mass.each_with_index do |element, i|
        if turn_on
          highlight element
        else
          unhighlight element
        end
      end
    end
  end
end

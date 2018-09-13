module Marta

  # Marta is creating a hash of element data. For now it stores
  # tag, text, and all the attributes.
  module ElementInformation

    private

    #
    # We are using helper class which can parse element attributes to our
    # special hash format.
    #
    # @note It is believed that no user will use it
    class ElementHelper

      def initialize(requestor)
        @engine = requestor.engine
      end

      # We can get data of the element or data of any parent.
      def get_element_info(element, parent_count = 0)
        parent = ''
        parent_count.times do
          parent = parent + '.parentElement'
        end
        result = Hash.new
        attr_script = %Q[
            var s = {};
            var attrs = arguments[0]#{parent}.attributes;
            for (var l = 0; l < attrs.length; ++l) {
                var a = attrs[l]; s[a.name] = a.value.split(" ");
            } ;
            return s;]
        tag_script = "return arguments[0]#{parent}.tagName"
        text_script = %Q[
        if (arguments[0]#{parent}.textContent == arguments[0]#{parent}.innerHTML)
           {return arguments[0]#{parent}.textContent} else {return ''};]
        result['tag'] = [@engine.execute_script(tag_script, element)]
        txt = @engine.execute_script(text_script, element)
        result['text'] = txt != '' ? [txt] : []
        result['attributes'] = @engine.execute_script(attr_script, element)
        result['attributes'].each_pair do |attribute, value|
          value.uniq!
        end
        return result
      end

      # That class is also stores an empty special format hash.
      def self.method_structure(collection = false)
        return {'options' => {'collection' => collection},
                 'positive' => {
                   'self' => {
                     'text'=>[], 'tag' => [], 'attributes' => {}},
                    'pappy' => {
                      'text'=>[], 'tag' => [], 'attributes' => {}},
                    'granny' => {
                      'text'=>[], 'tag' => [], 'attributes' => {}}},
                  'negative' => {
                    'self' => {
                      'text'=>[], 'tag' => [], 'attributes' => {}},
                     'pappy' => {
                       'text'=>[], 'tag' => [], 'attributes' => {}},
                     'granny' => {
                       'text'=>[], 'tag' => [], 'attributes' => {}}}
                    }
      end
    end

    # We are getting three levels of attributes of element,
    # parent and grandparent
    def get_attributes(element, requestor = self)
      result = Hash.new
      element_helper = ElementHelper.new requestor
      result['self'] = element_helper.get_element_info element
      result['pappy'] = element_helper.get_element_info element, 1
      result['granny'] = element_helper.get_element_info element, 2
      return result
    end

    # We can return the default structure of our special format
    def method_structure(collection = false)
      ElementHelper.method_structure collection
    end

  end
end

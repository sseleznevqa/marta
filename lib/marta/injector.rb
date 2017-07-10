require 'pry'
module Marta

  #
  # This module can add Marta's stuff to the page.
  #
  # Marta is inserting tons of stuff to the pages!
  # Those insertions are the only way for her to perform dialog with user
  module Injector

    private

    #
    # We are injecting things to the page using the Syringe.
    #
    # @note It is believed that no user will use it
    class Syringe

      def initialize(engine, marta_what, title = 'Something important',
                     old_data = Hash.new, folder = gem_libdir)
        @what = marta_what
        @title = title
        @data = old_data
        @engine = engine
        @folder = folder
      end

      # "first" or "last".
      def get_where(first)
        first ? "first" : "last"
      end

      # Inserting to the page
      def insert_to_page(tag, inner, first = true)
        where = get_where(first)
        script = <<-JS
        var newMartaObject = document.createElement('#{tag}');
        newMartaObject.setAttribute('martaclass','marta_#{tag}');
        newMartaObject.innerHTML   = '#{inner}';
        document.body.insertBefore(newMartaObject,document.body.#{where}Child);
        JS
         @engine.execute_script script.gsub("\n",'')
      end

      # Taking a correct js file to inject
      def js
        File.read(@folder + "/data/#{@what}.js").gsub("\n",'')
      end

      # Taking a correct html file to inject
      def html
        File.read(@folder + "/data/#{@what}.html").gsub("\n",'')
      end

      # Taking a correct css file to inject
      def style
        File.read(@folder + "/data/style.css").gsub("\n",'')
      end

      # Injecting everything to the page
      def files_to_page
        insert_to_page('div', html)
        insert_to_page('script', js, false)
        insert_to_page('style', style, false)
      end

      # It is never used without get_result.
      # But it can be used to show some message for user
      def actual_injection
        files_to_page
        @data ||= Hash.new
        insert_to_page('script', "var marta_what = \"#{@title}\"", false)
        insert_to_page('script',
                       "var old_marta_Data = #{@data}".gsub('=>',':').
                                                           gsub('nil','null'),
                       false)
        @engine.execute_script("marta_add_data();")
        if @what == 'element'
        #  binding.pry
        end
      end

      # Retrieving result if js var = marta_confirm_mark is true
      # we are returning js var = marta_result. So custom js should always
      # return both.
      def get_result
        result = false
        while result != true
          # When Marta can't get a result she is reinjecting her stuff
          begin
            result = @engine.execute_script("return marta_confirm_mark")
          rescue
            actual_injection
          end
        end
        @engine.execute_script("return marta_result")
      end
    end

    # That's how Marta is injecting and retrieving result
    def inject(what, title = 'Something important', data = Hash.new)
      syringe = Syringe.new(engine, what, title, data, gem_libdir)
      syringe.actual_injection
      #binding.pry
      syringe.get_result
    end
  end
end

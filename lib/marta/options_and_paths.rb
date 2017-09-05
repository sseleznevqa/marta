module Marta

  #
  # Marta can store and return settings which may differ for each thread
  #
  # Settings for Marta.
  # Most of them could be changed in action using dance_with.
  # Most of them are thread dependant.
  module OptionsAndPaths

    #
    # We are storing vars in a special class
    #
    # @note It is believed that no user will use it
    class SettingMaster
      @@folder = Hash.new
      @@tolerancy = Hash.new
      @@learn = Hash.new
      @@engine = Hash.new
      @@base_url = Hash.new
      @@cold_timeout = Hash.new

      # Getting uniq id for process thread
      def self.thread_id
        Thread.current.object_id
      end

      # Checking default learn option status
      def self.learn_option
        ENV['LEARN'].nil? ? false : true
      end

      # Marta knows does she learn or not.
      def self.learn_status
        if @@learn[thread_id].nil?
          learn_option
        else
          @@learn[thread_id]
        end
      end

      # Marta knows where are her saved generated pageobjects
      def self.pageobjects_folder
        @@folder[thread_id]
      end

      # Marta knows how hard she should search for elements
      def self.tolerancy_value
        @@tolerancy[thread_id]
      end

      # engine (analog of browser) is a setting too
      def self.engine
        @@engine[thread_id]
      end

      # Marta knows what web application she is trying to test
      def self.base_url
        @@base_url[thread_id]
      end

      # Time setting for Marta. She will wait that time before active search
      def self.cold_timeout
        @@cold_timeout[thread_id]
      end

      # Marta is changing parameters by the same scheme.
      def self.parameter_set(what, value, default)
        what[thread_id] = !value.nil? ? value : what[thread_id]
        what[thread_id] = what[thread_id].nil? ? default : what[thread_id]
        what
      end

      # Marta locates iframes sometimes
      def self.iframe_locate
        if !engine.nil?
          if engine.class == Watir::IFrame
            engine.locate
          end
        end
      end

      # Marta is switching to iframes sometimes
      def self.iframe_switch_to
        if !engine.nil?
          if engine.class == Watir::IFrame
            engine.switch_to!
          end
        end
      end

      # Marta is setting engine by pretty comlex rules
      def self.set_engine(value)
        if (engine.class == Watir::Browser) and (value.class == Watir::Browser)
          engine.close
        end
        iframe_locate
        @@engine = parameter_set(@@engine, value, nil)
        iframe_switch_to
        if engine.nil?
          @@engine = parameter_set(@@engine, value, Watir::Browser.new(:chrome))
        end
      end

      # Marta uses simple rules to set the folder
      def self.set_folder(value)
        @@folder = parameter_set(@@folder, value, 'Marta_s_pageobjects')
      end

      # Marta uses simple rules to set the laearn mode
      def self.set_learn(value)
        @@learn = parameter_set(@@learn, value, learn_option)
      end

      # Marta uses simple rules to set the tolerancy value
      def self.set_tolerancy(value)
        @@tolerancy = parameter_set(@@tolerancy, value, 1024)
      end

      def self.parameter_check_and_set(where, value, default, expected_class)
        if (value.nil?) or (value.class == expected_class)
          where = parameter_set(where, value, default)
        else
          raise ArgumentError, "The value should be a #{expected_class}."\
                               " Not a #{value}:#{value.class}"
        end
      end

      # Marta uses a simple rule to set the basic url.
      def self.set_base_url(value)
        parameter_check_and_set(@@base_url, value, "", String)
      end

      # Marta uses simple rule to set the cold timeout
      def self.set_cold_timeout(value)
        parameter_check_and_set(@@cold_timeout, value, 10, Fixnum)
      end
    end

    private

    # Defining the place for files to inject to browser
    def gem_libdir
      t = ["#{Dir.pwd}/lib/#{Marta::NAME}",
           "#{Gem.dir}/gems/#{Marta::NAME}-#{Marta::VERSION}/lib/#{Marta::NAME}"]
      File.readable?(t[0])? t[0] : t[1]
    end

    # Marta knows does she learn or not.
    def learn_status
      SettingMaster.learn_status
    end

    # Marta knows where are her saved generated pageobjects
    def pageobjects_folder
      SettingMaster.pageobjects_folder
    end

    # Marta knows how hard she should search for elements
    def tolerancy_value
      SettingMaster.tolerancy_value
    end

    # Marta knows the basic url of the projec. If it is defined
    def base_url
      SettingMaster.base_url
    end

    def cold_timeout
      SettingMaster.cold_timeout
    end
  end
end

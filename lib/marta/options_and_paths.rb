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
      @@port = Hash.new
      @@server = Hash.new

      def self.clear
        @@folder[thread_id] = nil
        @@tolerancy[thread_id] = nil
        @@learn[thread_id] = nil
        if @@engine[thread_id].class == Watir::Browser
          @@engine[thread_id].quit
        end
        @@engine[thread_id] = nil
        @@base_url[thread_id] = nil
        @@cold_timeout[thread_id] = nil
        @@port[thread_id]
        @@port[thread_id] = nil
        @@server[thread_id]
        if @@server[thread_id].class == Marta::Server::MartaServer
          @@server[thread_id].server_kill
        end
        @@server[thread_id] = nil
      end

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

      # Marta knows the server port.
      def self.port
        @@port[thread_id]
      end

      # Marta stores the server as a setting.
      def self.server
        @@server[thread_id]
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
        if (engine.class == Watir::Browser) and
           (value.class == Watir::Browser) and
           (engine != value)
             engine.quit if engine.exists?
        end
        iframe_locate
        @@engine = parameter_set(@@engine, value, nil)
        iframe_switch_to
        if engine.nil?
          browser = Watir::Browser.new(:chrome,
                    switches: ["--load-extension=#{gem_libdir}/marta_app"])
                    browser.goto "127.0.0.1:#{SettingMaster.port}/welcome"
          @@engine = parameter_set(@@engine, value, browser)
        end
      end

      # Marta uses simple rules to set the folder
      def self.set_folder(value)
        @@folder = parameter_set(@@folder, value, 'Marta_s_pageobjects')
      end

      # Marta uses simple rules to set the laearn mode
      def self.set_learn(value)
        @@learn = parameter_set(@@learn, value, learn_option)
        if learn_status
          warn "Be carefull. If browser was not started by Marta."\
          " Learn mode will not work properly"
        else
          # We are switching server off if we do not really need it
          SettingMaster.server.server_kill
        end
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
        parameter_check_and_set(@@cold_timeout, value, 10, Integer)
      end

      # Marta sets port. If it is not defined and there are number of threads
      # Marta will use ports from 6260 one by one (6260, 6261, 6262,...)
      def self.set_port(value)
        i = 0
        if value.nil?
          while Server::MartaServer.port_check(6260 + @@port.size + i)
            i += 1
          end
        end
        parameter_check_and_set(@@port, value, 6260 + @@port.size + i, Integer)
      end

      # We are storaging server instance as a setting
      def self.set_server
        if SettingMaster.server.nil?
          @@server[thread_id] = Server::MartaServer.new(SettingMaster.port)
        elsif SettingMaster.server.current_port != SettingMaster.port
          @@server[thread_id] = Server::MartaServer.new(SettingMaster.port)
        end
      end

      # Marta knows where is she actually is.
      def self.gem_libdir
        t = ["#{Dir.pwd}/lib/#{Marta::NAME}",
             "#{Gem.dir}/gems/#{Marta::NAME}-#{Marta::VERSION}/lib/#{Marta::NAME}"]
        File.readable?(t[0])? t[0] : t[1]
      end
    end

    private

    # Defining the place for files to inject to browser
    def gem_libdir
      SettingMaster.gem_libdir
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

    # Marta knows the basic url of the project. If it is defined
    def base_url
      SettingMaster.base_url
    end

    # Marta stores a cold_timeout value
    def cold_timeout
      SettingMaster.cold_timeout
    end

    #Marta stores port for Marta server for each thread.
    def port
      SettingMaster.port
    end

    # Marta can call server easily
    def server
      SettingMaster.server
    end

    # Marta knows was the browser started by she
    def correct_engine?
      SettingMaster.correct_engine?
    end
  end
end

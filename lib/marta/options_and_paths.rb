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
    end

    private

    # Defining the place for files to inject to browser
    def gem_libdir
      t = ["#{File.dirname(File.expand_path($0))}/../lib/#{Marta::NAME}",
           "#{Gem.dir}/gems/#{Marta::NAME}-#{Marta::VERSION}/lib/#{Marta::NAME}"]
      t.each {|i| return i if File.readable?(i) }
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

    # Marta is accepting parameters and rereading pageobjects on any change
    def dance_with(browser: nil, folder: nil, learn: nil, tolerancy: nil)
      SettingMaster.set_engine browser
      SettingMaster.set_folder folder
      SettingMaster.set_learn learn
      read_folder
      SettingMaster.set_tolerancy tolerancy
      engine
    end
  end
end

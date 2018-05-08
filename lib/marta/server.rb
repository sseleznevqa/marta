require 'webrick'
require 'marta/options_and_paths'
require 'pry'

module Marta

  #
  # Marta's server is an interface that will make Marta more interactive.
  #
  # Marta's server is a new way for Marta to communicate with the world.
  # Right now it will be responsible for dialog operations only.
  module Server

    include OptionsAndPaths

    private

    #
    # Servlet to be used to understand is dialog answer provided or not
    #
    # @note It is believed that no user will use it
    class DialogServlet < WEBrick::HTTPServlet::AbstractServlet
      @@has_answer = nil
      @@touch_port = nil

      def self.has_answer
        @@has_answer
      end

      def self.touch_port
        @@touch_port
      end

      def self.drop
        @@has_answer, @@touch_port = nil, nil
      end

      def do_GET (request, response)
        @@touch_port = request.port
        response.status = 200
        response.content_type = "text/plain"
        @@has_answer = case request.path
                       when '/dialog/got_answer'
                         true
                       when '/dialog/lost'
                         nil
                       when '/dialog/not_answer'
                         false
                       end
        response.body = "Ok!"
      end
    end

    #
    # Server control and logic is in the class.
    #
    # @note It is believed that no user will use it
    class MartaServer

      include OptionsAndPaths

      def initialize(port = SettingMaster.port)
        @@thread = Thread.new(port) do |port|
          the_server_start(port)
          Thread.stop
        end
      end

      def self.thread
        @@thread
      end

      def the_server_start(port)
        the_server = WEBrick::HTTPServer.new(Port: port,
                   Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
                   AccessLog: WEBrick::Log.new(File.open(File::NULL, 'w')))
        the_server.mount "/dialog", DialogServlet
        the_server.start
        port
      end

      def self.server_check
        if !@@thread.alive?
          warn "Marta server was not started properly"
          @@thread.join
        else
          true
        end
      end

      def self.wait_user_dialog_response(port)
        server_check
        DialogServlet.drop
        start_time = Time.now
        while (DialogServlet.touch_port != port) and (Time.now - start_time < 2)
          # Since endless loop is a bad idea...
        end
        if (DialogServlet.touch_port != port)
          false
        else
          DialogServlet.has_answer
        end
      end
    end
  end
end

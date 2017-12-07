require 'webrick'

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
        puts "SEE!"
        @@touch_port = request.port
        response.status = 200
        response.content_type = "text/plain"
        if request.path == '/got_answer'
          @@has_answer = true
        else
          @@has_answer = false
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
        Thread.new do
          the_server = WEBrick::HTTPServer.new(:Port => port)
          the_server.mount "/dialog", DialogServlet
          the_server.start
        end
      end

      def self.wait_user_dialog_response(port)
        DialogServlet.drop
        start_time = Time.now
        while (DialogServlet.touch_port != port) and (Time.now - start_time < 2)
          # Since endless loop is a bad idea...
        end
        if (DialogServlet.touch_port != port)
          nil
        else
          DialogServlet.has_answer
        end
      end
    end
  end
end

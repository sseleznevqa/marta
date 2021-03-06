require 'webrick'
require 'marta/options_and_paths'

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
    # Special class is used for storing internal variables of the server
    #
    # @note It is believed that no user will use it
    class ServerStore

      # Getting info about dialog state
      def self.has_answer
        @@has_answer
      end

      # Setting info about the dialog state.
      def self.has_answer=(value)
        @@has_answer = value
      end
    end

    #
    # Servlet to be used to understand is dialog answer provided or not
    #
    # @note It is believed that no user will use it
    class DialogServlet < WEBrick::HTTPServlet::AbstractServlet

      # What our server will do on get request
      def do_GET (request, response)
        ServerStore.has_answer = nil
        response.status = 200
        response.content_type = "text/plain"
        ServerStore.has_answer = case request.path
                                 when '/dialog/got_answer'
                                   true
                                 when '/dialog/not_answer'
                                   false
                                 end
        response.body = "#{Thread.current.object_id}"
      end
    end

    #
    # Welcome Servlet
    #
    # @note It is believed that no user will use it
    class WelcomeServlet < WEBrick::HTTPServlet::AbstractServlet
      def do_GET (request, response)
        response.status = 200
        response.content_type = "text/html"
        response.body = "<html><body><h1>Welcome!</h1></hr><h2>If You can "\
        "see this label most probably Marta is working. I hope.</h2></hr>"\
        "<a href='https://github.com/sseleznevqa/marta'>GITHUB link</a>"\
        "</body></html>"
      end
    end

    #
    # Server control and logic is in the class.
    #
    # @note It is believed that no user will use it
    class MartaServer

      include OptionsAndPaths

      def initialize(port = SettingMaster.port)
        @port = port
        @@thread = Thread.new(port) do |port|
          begin
            the_server_start(port)
          rescue
            raise RuntimeError, "Could not start the server!"
            @@thread.kill
          end
        end
        MartaServer.server_check
      end

      # Here we will store the thread where server is living
      def self.thread
        @@thread
      end

      # Server is starting with mounts.
      def the_server_start(port)
        the_server = WEBrick::HTTPServer.new(Port: port,
                   Logger: WEBrick::Log.new(File.open(File::NULL, 'w')),
                   AccessLog: WEBrick::Log.new(File.open(File::NULL, 'w')))
        the_server.mount "/dialog", DialogServlet
        the_server.mount "/welcome", WelcomeServlet
        the_server.mount_proc('/q') {|req, resp| the_server.shutdown;  exit;}
        the_server.start
      end

      # Marta knows when server is not okay
      def self.server_check
        if !@@thread.alive?
          warn "Marta server was not working properly"
          @@thread.join
        else
          true
        end
      end

      def self.port_check(port)
        Timeout::timeout(1) do
          begin
            TCPSocket.new('127.0.0.1', port).close
            true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            false
          end
        end
      rescue Timeout::Error
        false
      end

      # We are killing the server sometimes
      def server_kill
        # So nasty. But WEBrick knows what to do.
        while @@thread.alive?
          @@thread.exit
        end
        @@thread.join
      end

      # Server can wait for while somebody will touch it
      def self.wait_user_dialog_response(wait_time = 600)
        ServerStore.has_answer = nil
        server_check
        start_time = Time.now
        while ServerStore.has_answer.nil? and (Time.now - start_time < wait_time)
          # No idea what Am I doing here...
        end
        ServerStore.has_answer
      end
    end
  end
end

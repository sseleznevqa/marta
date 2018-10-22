require 'webrick'
require 'marta/options_and_paths'
require 'markaby'

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

    class TimeServlet < WEBrick::HTTPServlet::AbstractServlet
      @@data = Time.now.to_s
      def self.data=(value)
        @@data = value
      end

      def self.data
        @@data
      end

      def do_GET (request, response)
        response.status = 200
        response.content_type = "text/html"
        response.body = @@data
      end
    end

    class FormServlet < WEBrick::HTTPServlet::AbstractServlet

      @@data = {title:"Welcome!!!",
                subtitle:"If you can see this label most probably Marta is working.",
                hints:["I hope."],
                links:[{title: "GITHUB link", href:"https://github.com/sseleznevqa/marta"}],
                vars:{}, # {"var" => "value"},
                checks:{collection: nil, dontlook: nil},
                buttons: []} # [{title:"", onclck:"", type:""}]}

      def self.data=(value)
        @@data = value
        TimeServlet.data = Time.now.to_s
      end

      def self.data
        @@data
      end

      def form
        answer = Markaby::Builder.new
        answer.html do
          head { title @@data[:title] }
          body do
            h1 @@data[:title]
            h2 @@data[:subtitle]
            @@data[:hints].each do |hint|
              h3 hint
            end
            @@data[:links].each do |link|
              a link[:title], href: link[:href]
            end
            form(id: "marta_main_dialog_form") do
              div do # variables
                @@data[:vars].each_pair do |name, value|
                  input value: name, type: 'text'
                  input value: value, type: 'text'
                end
              end # variables div
              div do # checkboxes
                @@data[:checks].each_pair do |name, check|
                  if !check.nil?
                    label {input value: check, type: 'checkbox'}
                  end
                end
              end # checkboxes div
              div do # buttons
                @@data[:buttons].each do |button|
                  input value: button[:title],
                        type: button[:type],
                        onclick: button[:onclick]
                end
              end # buttons div
            end # form
          end # body
        end # html
        return answer.to_s
      end

      def content
        answer = Markaby::Builder.new
        answer.html do
          head { title "Welcome!!!" }
          body do
            h1 "Welcome!!!"
            h2 "If you can see this label most probably Marta is working."
            h3 "I hope."
            a "GITHUB link", href: 'https://github.com/sseleznevqa/marta'
          end
        end
        return answer.to_s
      end

      def do_GET (request, response)
        response.status = 200
        response.content_type = "text/html"
        response.body = form
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
        the_server.mount "/welcome", FormServlet
        the_server.mount "/updated", TimeServlet
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

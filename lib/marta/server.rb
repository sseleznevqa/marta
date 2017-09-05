module Marta

  # Marta should be able to show her files to the webpages.
  # Also it can be used later as a better way to communicate between
  # Marta in browser and Marta in the code
  module Server

    private

    class MartaServer
      def initialize(port = 6262, folder = gem_libdir)
        Thread.new do
          WEBrick::HTTPServer.new(:Port => port,
                                  :DocumentRoot => "/#{folder}/data/"
                                  :AccessLog => [],
                                  :Logger => WEBrick::Log::new("/dev/null", 7))
                                  .start
        end
      end
    end
  end
end

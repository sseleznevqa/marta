require 'marta/options_and_paths'
module Marta

  # Marta has very simple read\write actions
  module ReadWrite

    private

    #
    # Sometimes marta reads files. Sometimes writes
    #
    # @note It is believed that no user will use it
    class ReaderWriter
      include OptionsAndPaths
      # Marta is writing to jsons from time to time
      def self.file_write(name, data)
        file_name = File.join(SettingMaster.pageobjects_folder, name + '.json')
        File.open(file_name,"w") do |f|
          f.write(data.to_json)
        end
        file_name
      end

      # Marta reads file to hash if it is a valid json
      # If it is not a json file Marta will treat it like nothing
      def self.file_2_hash(json)
        begin
          file = File.read(json)
          data = JSON.parse(file)
        rescue
          nil
        end
      end
    end

    def file_write(name, data)
      ReaderWriter.file_write(name, data)
    end

    def file_2_hash(json)
      ReaderWriter.file_2_hash(json)
    end
  end
end

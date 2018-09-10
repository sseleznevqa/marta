require 'marta/options_and_paths'
require 'marta/element_information'
module Marta

  # Marta has very simple read\write actions
  module ReadWrite

    include ElementInformation

    private

    #
    # Sometimes marta reads files. Sometimes writes
    #
    # @note It is believed that no user will use it
    class ReaderWriter
      include OptionsAndPaths, ElementInformation
      # Marta is writing to jsons from time to time
      def self.file_write(name, data)
        file_name = File.join(SettingMaster.pageobjects_folder, name + '.json')
        File.open(file_name,"w") do |f|
          f.write(JSON.pretty_generate(data))
        end
        file_name
      end

      # Marta reads file to hash if it is a valid json
      # If it is not a json file Marta will treat it like nothing
      def self.file_2_hash(json)
        begin
          file = File.read(json)
          data = JSON.parse(file)
          # If there are methods
          if data['meths'] != {}
            # If there are old methods
            if !data['meths'].first[1]['options']['self'].nil? or !data['meths'].first[1]['options']['not_self'].nil?
              data = treat_old_version(data)
              File.open(json,"w") do |f|
                f.write(JSON.pretty_generate(data))
              end
            end
          end
          return data
        rescue
          nil
        end
      end

      def self.treat_old_version(data)
        result, result['meths'] = Hash.new, Hash.new
        result['vars'] = data['vars']
        # Taking all methods one by one
        data['meths'].each_pair do |method, method_content|
          result['meths'][method] = ElementHelper.method_structure
          result['meths'][method]['options']['collection'] = method_content['options'].to_h['collection']
          ['self','pappy','granny'].each do |level|
            if !method_content['options'].to_h[level].nil?
              result['meths'][method]['positive'][level]['tag'] = [method_content['options'][level]] - ['*']
            end
            if !method_content[level].to_h['retrieved_by_marta_text'].nil?
              result['meths'][method]['positive'][level]['text'] = [method_content[level]['retrieved_by_marta_text']]
            end
            method_content[level].to_h.each_pair do |name, value|
              if name != "retrieved_by_marta_text"
                result['meths'][method]['positive'][level]['attributes'][name] = value.class == String ? value.split(' ').uniq : value
              end
            end
            if !method_content['options'].to_h["not_#{level}"].nil?
              result['meths'][method]['negative'][level]['tag'] = [method_content['options']["not_#{level}"]] - ['*']
            end
            if !method_content["not_#{level}"].to_h['retrieved_by_marta_text'].nil?
              result['meths'][method]['negative'][level]['text'] = [method_content["not_#{level}"]['retrieved_by_marta_text']]
            end
            method_content["not_#{level}"].to_h.each_pair do |name, value|
              if name != "retrieved_by_marta_text"
                result['meths'][method]['negative'][level]['attributes'][name] = value.class == String ? value.split(' ').uniq : value
              end
            end
          end
        end
        result
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

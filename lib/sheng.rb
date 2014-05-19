#
# Sheng::Docx - is a base Mediator whitch delegates responsibilities
# to another sheng singleton classes, which replace their part of xml.
#

require 'active_support/inflector'
require 'sheng/support'
require 'sheng/version'
require 'sheng/helpers'
require 'sheng/replacer_base'
require 'sheng/sequences'
require 'sheng/check_boxes'
require 'sheng/tables'
require 'sheng/strings'
require 'sheng/exceptions'

require 'zip'
require 'nokogiri'
require 'fileutils'
require 'sheng/helpers'
require 'json'

module Sheng
  class Docx
    include Sheng::Helpers
    #
    # Avaliable keys and Mutable xml documents
    #
    PARAMS_KEYS = [:sequences, :check_boxes, :tables, :strings]
    PARTS_FOR_REPLACE_REGEX = [/word\/document.xml/, /word\/numbering.xml/, /word\/header(\d)*.xml/, /word\/footer(\d)*.xml/]

    def initialize(docx_file, params_json)
      @zip_file = docx_file.is_a?(String) ? Zip::File.new(docx_file) : Zip::File.open(docx_file.path)
      #
      # params_json.to_s - adds availability to receive params json as json or Hash
      #
      @params_hash = Sheng::Support.symbolize_keys( params_json.is_a?(Hash) ? params_json : JSON.parse(params_json) )
    rescue Zip::ZipError, JSON::ParserError => e
      raise InputArgumentError.new(e.message)
    end

    #
    # generate and save docx file with replaced mergefields
    #
    def generate path
      buffer = Zip::OutputStream.write_buffer do |out|
        begin
          @zip_file.entries.each do |entry|
            if entry_for_replacing?(entry.name)
              out.put_next_entry(entry.name)
              out.write replace(entry.name).to_s
            else
              out.put_next_entry(entry.name)
              out.write entry.get_input_stream.read
            end
          end
        ensure
          out.close_buffer
        end
      end

      File.open(path, "w") {|f| f.write(buffer.string) }
    end

    private
    #
    # delegates replace functionality to apropriate class
    #
    def replace file_path
      xml = PARAMS_KEYS.each_with_object(Nokogiri::XML(@zip_file.read(file_path))) do |k, xml|
        instance = "Sheng::#{k.to_s.camelize}".constantize.new
        xml = instance.replace(@params_hash[k], xml) if @params_hash.include?(k)
      end

      fields = get_unmerged_fields(xml)
      raise Sheng::MergefieldNotReplacedError.new(fields) if fields.size > 0
      xml
    end

    def entry_for_replacing?(file_name)
      PARTS_FOR_REPLACE_REGEX.any?{|regex| file_name.match(regex)}
    end
  end
end

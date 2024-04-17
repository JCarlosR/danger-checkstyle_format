# frozen_string_literal: true

require_relative "checkstyle_error"

module Danger
  # Danger plugin for checkstyle xml files.
  #
  # @example Parse the XML file, and let the plugin do your reporting
  #
  #          checkstyle_format.base_regex = %r{^.*?\/src\/}
  #          checkstyle_format.report 'app/build/reports/checkstyle/checkstyle.xml'
  #
  # @example Parse the XML text, and let the plugin do your reporting
  #
  #          checkstyle_format.base_regex = %r{^.*?\/src\/}
  #          checkstyle_format.report_by_text '<?xml ...'
  #
  # @see  noboru-i/danger-checkstyle_format
  # @tags lint, reporting
  #
  class DangerCheckstyleFormat < Plugin
    # Base regex for converting the full paths into relative paths.
    # Defaults to nil.
    # @return [String]
    attr_accessor :base_regex

    # Report checkstyle warnings
    #
    # @return   [void]
    def report(file, inline_mode: true)
      raise "Please specify file name." if file.empty?
      raise "No checkstyle file was found at #{file}" unless File.exist? file

      errors = parse(File.read(file))

      send_comment(errors, inline_mode)
    end

    # Report checkstyle warnings by XML text
    #
    # @return   [void]
    def report_by_text(text, inline_mode: true)
      raise "Please specify xml text." if text.empty?

      errors = parse(text)

      send_comment(errors, inline_mode)
    end

    private

    def parse(text)
      require "ox"

      doc = Ox.parse(text)

      present_elements = doc.nodes.first.nodes.reject do |test|
        test.nodes.empty?
      end

      present_elements.flat_map do |parent|
        parent.nodes.map do |child|
          CheckstyleError.generate(child, parent, @base_regex)
        end
      end
    end

    def send_comment(errors, inline_mode)
      if inline_mode
        send_inline_comment(errors)
      else
        # TODO: not implemented.
        raise "Not implemented."
      end
    end

    def send_inline_comment(errors)
      errors.each do |error|
        # puts "Sending inline comment to file #{error.file_name}, line #{error.line}"
        warn(error.message, file: error.file_name, line: error.line)
      end
    end
  end
end

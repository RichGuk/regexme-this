require 'json'
require 'escape'

module Regex

  module Errors
    class UnsupportedLanguage < Exception; end
    class MatchException < Exception; end
  end # Errors.

  # Native Regex tester class for Ruby, all other languages are passed onto
  # shell scripts.
  class Ruby

    REGEX_OPTIONS = { 'i' => Regexp::IGNORECASE,
                      'm' => Regexp::MULTILINE,
                      'x' => Regexp::EXTENDED }

    # Converts String into Regexp if not so already.
    #
    # @param [String, Regexp] regex the regular expression to convert
    #
    # @return [Regexp] Compiled Regexp instance
    #
    # @private
    def compile_regex(regex, options)
      return regex if regex.is_a?(Regexp)

      options = REGEX_OPTIONS.inject(0) do |total, item|
        total |= item[1] if options && options.include?(item[0])
        total
      end
      begin
        Regexp.compile(regex, options)
      rescue RegexpError => e
        raise Errors::MatchException, e
      end
    end

    # Find matches in the given data based upon a regular expression.
    #
    # @param [String, Regexp] regex the regular expression for the match
    # @param [String] data the content to perform the match against
    # @param [String] options Any regex options, such as ignore case, etc...
    #
    # @return [Hash] Any matches and any named group matches.
    def match(regex, data, options)
      regex = self.compile_regex(regex, options)
      {:matches => data.match(regex).to_a}
    end

    # Find regular expression matches anywhere in the data.
    #
    # @param [String, Regexp] regex the regular expression for the match
    # @param [String] data the content to perform the match against
    # @param [String] options Any regex options, such as ignore case, etc...
    #
    # @return [Hash] Any matches and any named group matches.
    def match_all(regex, data, options)
      regex = self.compile_regex(regex, options)
      {:matches => data.scan(regex).to_a}
    end

    # Replace matched regex items in the content with the replace data.
    #
    # @param [String, Regexp] regex the regular expression
    # @param [String] replace_data the string to replace found matches with
    # @param [String] data the data to perform the match against
    #
    # @return [Hash] The replaced data is returned
    def replace(regex, data, replace_data, options)
      regex = self.compile_regex(regex, options)
      {:replaced_data => data.gsub(regex, replace_data)}
    end
  end # Ruby

  class Tester
    SUPPORTED_LANGUAGES = ['ruby', 'python']
    attr_accessor :language

    def initialize(lang)
      raise Errors::UnsupportedLanguage, lang unless
        SUPPORTED_LANGUAGES.include?(lang)

      @language = lang
      @ruby = Regex::Ruby.new if @language == 'ruby'
    end

    # Determine the script location for each language.
    #
    # @return [String] Path and Filename of the language script
    #
    # @private
    def choose_script
      case @language
      when 'python'
        file = 'regex.py'
      end
      File.join(File.dirname(__FILE__), 'testers', file)
    end

    # Run the language script, with the appropriate arguments to receive
    # the languages regex matching response.
    #
    # @param [String] type the type of regex command (match, etc)
    # @param [Hash] opts the command line arguments for the script
    # @option opts [String] :regex the regular expression to perform
    # @option opts [String] :data the data the regex is performed against
    # @option opts [String] :options regex options, ignore case etc...
    #
    # @return [String] JSON reponse returned by the script
    #
    # @private
    def run_command(type, opts = {})
      regex, data, options, replace_data = opts.delete(:regex),
        opts.delete(:data), opts.delete(:options), opts.delete(:replace_data)

      return nil if type.nil? || regex.nil?

      args = Escape.shell_command(['--type', type, '--regex', regex,
          '--regex-options', options])
      if replace_data
        args += ' '
        args += Escape.shell_command(['--replace-data', replace_data])
      end

      `/usr/bin/env #{@language} #{self.choose_script} #{args} '#{data}'`
    end

    # Turn the JSON response into the correct hash items.
    #
    # @param [String] response the JSON
    #
    # @raise [MatchException] Raised if unable to parse JSON response
    #
    # @return [Hash] Contains any matches and named groups
    #
    # @private
    def parse_response(response = nil)
      response = JSON.parse(response)

      unless response[:error].nil?
        raise Errors::MatchException, response[:error]
      end

      # Return the hash of matches.
      {:matches => (response['matches'] || ''),
       :named_matches => (response['named_matches'] || ''),
       :replaced_data => (response['replaced_data'] || '')}
    rescue JSON::ParserError
      raise Errors::MatchException, 'Unable to parse JSON response'
    end

    # Find matches in the given data based upon a regular expression.
    #
    # @param [String, Regexp] regex the regular expression for the match
    # @param [String] data the content to perform the match against
    # @param [String] options Any regex options, such as ignore case, etc...
    #
    # @return [Hash] Any matches and any named group matches.
    def match(regex, data, options = '')
      raise Errors::MatchException, "Regex can't be empty" if regex.empty?
      return @ruby.match(regex, data, options) if @language == 'ruby'

      cmd = self.run_command('match', {:regex => regex, :data => data,
        :options => options})
      self.parse_response(cmd)
    end

    # Find regular expression matches anywhere in the data.
    #
    # @param [String, Regexp] regex the regular expression for the match
    # @param [String] data the content to perform the match against
    # @param [String] options Any regex options, such as ignore case, etc...
    #
    # @return [Hash] Any matches and any named group matches.
    def match_all(regex, data, options = '')
      raise Errors::MatchException, "Regex can't be empty" if
        regex.nil? || regex.empty?
      return @ruby.match_all(regex, data, options) if @language == 'ruby'

      cmd = self.run_command('match_all', {:regex => regex, :data => data,
        :options => options})
      self.parse_response(cmd)
    end

    # Replaces and regex matches in the data with the replace data.
    #
    # @param [String, Regexp] regex the regular expression
    # @param [String] replace_data the string to replace found matches with
    # @param [String] data the data to perform the match against
    #
    # @return [Hash] The replaced data
    def replace(regex, data, replace_data, options = '')
      raise Errors::MatchException, "Regex can't be empty" if regex.empty?
      return @ruby.replace(regex, data, replace_data, options) if @ruby

      cmd = self.run_command('replace', {:regex => regex, :data => data,
        :options => options, :replace_data => replace_data})
      self.parse_response(cmd)
    end
  end # Tester
end # Regex
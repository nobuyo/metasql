module Metasql
  class BaseError < StandardError; end

  # InvalidQueryError is caused by Metabase query syntax error.
  class InvalidQueryError < BaseError
    attr_reader :message

    def initialize(error_message)
      @message = error_message
      super
    end
  end

  # ParameterMissing causes when required param is not supplied.
  class ParameterMissing < BaseError
    attr_reader :key

    def initialize(key)
      @key = key
      super
    end

    def message
      "Required parameters missing: #{key}"
    end
  end
end

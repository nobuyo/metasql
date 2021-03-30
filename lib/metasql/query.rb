module Metasql
  # Query ...
  class Query
    attr_accessor :parsed, :mapping

    def initialize(parsed:, mapping: {})
      @parsed = parsed
      @mapping = mapping.transform_keys(&:to_sym)
    end

    def with(mapping)
      dup.tap { |q| q.mapping = mapping }
    end

    # Rebuild query from parsed tokens.
    # For supplying parameter value, call `with()` before this method.
    def deparse
      parsed.map do |token|
        case token
        when Metasql::Optional
          substitute_optional(query_array: token.query)
        when Metasql::Param
          substitute_param(param: token)
        else
          token
        end
      end.join
    end

    private

    def substitute_optional(query_array:)
      if query_array.select { |t| t.is_a?(Metasql::Param) }.map(&:name).none? { |n| mapping[n] }
        return ''
      end

      query_array.map do |m|
        if m.is_a?(Metasql::Param)
          quote_string(mapping[m.name])
        else
          m
        end
      end.join
    end

    def substitute_param(param:)
      raise Metasql::ParameterMissing, param.name unless mapping[param.name]

      quote_string(mapping[param.name])
    end

    def quote_string(value)
      if value.is_a?(Numeric)
        value
      else
        "'#{value}'"
      end
    end
  end
end

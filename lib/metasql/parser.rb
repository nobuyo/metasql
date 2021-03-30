module Metasql
  # Parser for Metabase flavored query.
  class Parser
    TOKENS = [
      { token: :optional_begin, pattern: '[[' },
      { token: :optional_end,   pattern: ']]' },
      { token: :param_begin,    pattern: /(.*?)({{(?!{))(.*)/m },
      { token: :param_end,      pattern: '}}' }
    ].map(&:freeze).freeze

    # Generate new Metasql::Query from supplied string.
    def self.parse(query)
      parser = new(query: query)
      tokenized = parser.tokenize
      parsed = parser.parse_tokens(tokens: tokenized)

      Query.new(parsed: parsed)
    end

    attr_reader :query

    def initialize(query:)
      @query = query
    end

    def tokenize
      TOKENS.inject([query]) do |strs, token_definition|
        strs.map do |s|
          next [s] unless s.is_a?(String)

          acc = []
          target = s
          loop do
            break acc if target.nil?

            result = split_on_token(target: target, token: token_definition)
            break acc << target unless result.compact.size == 3

            acc.concat(result[0..1])
            target = result[2]
          end
        end.flatten
      end
    end

    def parse_tokens(tokens:, depth: 0)
      acc = []
      remains = tokens

      loop do
        token, *remains = remains

        if token.nil?
          if depth.positive?
            raise Metasql::InvalidQueryError,
                  "Invalid query: found '[[' or '{{' with no matching ']]' or '}}'"
          end

          break acc
        end

        if %i[optional_begin param_begin].include?(token)
          parsed, remains = parse_tokens(tokens: remains, depth: depth + 1)
          acc << send(token.to_s.split('_').first, parsed)

          next [acc, remains]
        end

        if %i[optional_end param_end].include?(token)
          acc << { optional_end: ']]', param_end: '}}' }[token] unless depth.positive?

          break [acc, remains]
        end

        acc << token
      end
    end

    private

    def param(args)
      name, *other = args
      if other.size > 1 || !name.is_a?(String)
        raise Metasql::InvalidQueryError, "Invalid '{{...}}' clause: expected a param name"
      end

      Param.new(name)
    end

    def optional(parsed)
      if parsed.none? { |t| t.is_a?(Param) }
        raise Metasql::InvalidQueryError,
              "'[[...]]' clauses must contain at least one '{{...}}' clause."
      end

      Optional.new(parsed)
    end

    def split_on_token(target:, token:)
      case token[:pattern]
      when String
        before, after = target.split(token[:pattern], 2)
      when Regexp
        before, _, after = token[:pattern].match(target)&.captures
      end

      [before, token[:token], after]
    end
  end
end

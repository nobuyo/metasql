module Metasql
  # Param represents required parameter in Metabase query.
  class Param
    attr_accessor :name

    def initialize(name)
      @name = name.strip.to_sym
    end
  end

  # Optional represents optional clause in Metabase query.
  class Optional
    attr_accessor :query

    def initialize(query)
      @query = query
    end
  end
end

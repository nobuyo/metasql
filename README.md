# Metasql

[![Gem](https://img.shields.io/gem/v/metasql?style=flat-square)](https://rubygems.org/gems/metasql)
[![GitHub](https://img.shields.io/github/license/nobuyo/metasql?style=flat-square)](https://github.com/nobuyo/metasql/blob/master/LICENSE)

Metasql is Metabase flavored query preprocessor.
Provides parameter substitution, optional clause deletion, etc.

# Getting Started

```ruby
require 'metasql'

sql = <<~SQL
  SELECT
      *
  FROM
      items
  WHERE
      foo = TRUE
      AND bar = {{ bar }}
      [[
          AND
          CASE WHEN {{ baz }} < 10
          THEN baz = {{ baz }}
          ELSE TRUE
      ]]
SQL

query = Metasql::Parser.parse(sql)

parameters = {
  bar: 'hi',
  baz: 10
}

# with parameter
print query.with(parameters).deparse
# =>  SELECT
#         *
#     FROM
#         items
#     WHERE
#         foo = TRUE
#         AND bar = 'hi'
#
#             AND
#             CASE WHEN 10 < 10
#             THEN baz = 10
#             ELSE TRUE

# without parameter
print query.deparse
# => Metasql::ParameterMissing: Required parameters missing: bar

# partially supply parameter
print query.with({ bar: 'hi' }).deparse
# =>  SELECT
#         *
#     FROM
#         items
#     WHERE
#         foo = TRUE
#         AND bar = 'hi'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nobuyo/metasql.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

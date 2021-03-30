RSpec.describe Metasql do
  context 'queries with no param' do
    let(:queries) do
      [
        {
          raw: 'select * from foo where bar=1',
          processed: 'select * from foo where bar=1'
        }
      ]
    end

    it 'parse & deparse generates correct query' do
      queries.map do |query|
        expect(Metasql::Parser.parse(query[:raw]).deparse).to eq query[:processed]
      end
    end
  end

  context 'queries with one param' do
    let(:queries) do
      [
        {
          raw: 'select * from foo where bar={{baz}}',
          processed: 'select * from foo where bar=1',
          parameters: { baz: 1 }
        },
        {
          raw: 'select * from foo where bar={{baz}}',
          processed: "select * from foo where bar='hello'",
          parameters: { baz: 'hello' }
        }
      ]
    end

    it 'parse & deparse generates correct query' do
      queries.map do |query|
        expect(Metasql::Parser.parse(query[:raw]).with(query[:parameters]).deparse).to eq query[:processed]
      end
    end

    it 'should raise error when not supplied value to required params' do
      queries.map do |query|
        expect do
          Metasql::Parser.parse(query[:raw]).deparse
        end.to raise_error(Metasql::ParameterMissing)
      end
    end
  end

  context 'queries with multiple params' do
    let(:queries) do
      [
        {
          raw: 'select * from foo where bar={{baz}} and chit={{chat}}',
          processed: 'select * from foo where bar=1 and chit=5',
          parameters: { baz: 1, chat: 5 }
        },
        {
          raw: 'select * from foo where bar={{baz}}\n or chit={{chit}}',
          processed: "select * from foo where bar='hello'\\n or chit='chat'",
          parameters: { baz: 'hello', chit: 'chat' }
        }
      ]
    end

    it 'parse & deparse generates correct query' do
      queries.map do |query|
        expect(Metasql::Parser.parse(query[:raw]).with(query[:parameters]).deparse).to eq query[:processed]
      end
    end
  end

  context 'queries with one optional clause' do
    let(:queries) do
      [
        {
          raw: 'select * from foo where true [[and bar={{baz}}]]',
          processed: 'select * from foo where true and bar=1',
          processed_without_paramter: 'select * from foo where true ',
          parameters: { baz: 1 }
        },
        {
          raw: 'select * from foo where true [[and bar={{baz}}]]',
          processed: 'select * from foo where true ',
          processed_without_paramter: 'select * from foo where true ',
          parameters: { baz: nil }
        }
      ]
    end

    it 'parse & deparse generates correct query' do
      queries.map do |query|
        expect(Metasql::Parser.parse(query[:raw]).deparse).to eq query[:processed_without_paramter]
        expect(Metasql::Parser.parse(query[:raw]).with(query[:parameters]).deparse).to eq query[:processed]
      end
    end
  end

  context 'queries with multiple optional clauses' do
    let(:queries) do
      [
        {
          raw: 'select * from foo where true [[and bar={{baz}}]] [[and chit={{chat}}]]',
          processed: 'select * from foo where true and bar=1 ',
          processed_without_paramter: 'select * from foo where true  ',
          parameters: { baz: 1 }
        },
        {
          raw: 'select * from foo where true [[and bar={{baz}}]] [[and chit={{chat}}]]',
          processed: 'select * from foo where true  and chit=3',
          processed_without_paramter: 'select * from foo where true  ',
          parameters: { chat: 3 }
        },
        {
          raw: 'select * from foo where true [[and bar={{baz}}]] [[and chit={{chat}}]]',
          processed: "select * from foo where true and bar='hi' and chit=3",
          processed_without_paramter: 'select * from foo where true  ',
          parameters: { baz: 'hi', chat: 3 }
        }
      ]
    end

    it 'parse & deparse generates correct query' do
      queries.map do |query|
        expect(Metasql::Parser.parse(query[:raw]).deparse).to eq query[:processed_without_paramter]
        expect(Metasql::Parser.parse(query[:raw]).with(query[:parameters]).deparse).to eq query[:processed]
      end
    end
  end

  context 'invalid queries' do
    let(:queries) do
      [
        {
          raw: 'select * from foo where bar={{}'
        },
        {
          raw: 'select * from foo where true [[ and bar=1 ]]'
        },
        {
          raw: 'select * from foo [[where bar = {{baz}}'
        }
      ]
    end

    it 'should raise error' do
      queries.map do |query|
        expect do
          Metasql::Parser.parse(query[:raw]).deparse
        end.to raise_error(Metasql::InvalidQueryError)
      end
    end
  end
end

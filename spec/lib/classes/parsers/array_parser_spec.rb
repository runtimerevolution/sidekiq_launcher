# frozen_string_literal: true

require 'spec_helper'
require 'classes/parsers/array_parser'

RSpec.describe SidekiqLauncher::ArrayParser do
  let(:legal_strings) do
    ['[]', '[1, 2, 3]', '["a", "b", "c"]', '[{ abc: 1, def: 2 }, {ghi: 3, jkl: 4}]', '[true, false]',
     '["numbers", "and", "strings", 1]']
  end
  let(:illegal_strings) do
    ['', '["incomplete", "array"', '"incomplete", "array"]',
     'some_string', '123', 'true', '1.0', '{ some: 1, hash: 2 }', '{ "json": 1, "hash": 2 }']
  end

  it 'validates legal strings' do
    legal_strings.each do |str|
      expect(subject.validate?(str)).to(be(true))
    end
  end

  it 'rejects illegal strings' do
    illegal_strings.each do |str|
      expect(subject.validate?(str)).to(be(false))
    end
  end

  it 'parses legal strings' do
    legal_strings.each do |str|
      expect(subject.try_parse(str)).to(be_a(Array))
    end
  end

  it 'does not parse illegal strings' do
    illegal_strings.each do |str|
      expect(subject.try_parse(str)).to(be_nil)
    end
  end
end

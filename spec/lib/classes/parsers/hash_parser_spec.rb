# frozen_string_literal: true

require 'spec_helper'
require 'classes/parsers/hash_parser'

RSpec.describe SidekiqLauncher::HashParser do
  let(:legal_strings) do
    ['{}', '{ some: 1, hash: 2 }', '{ "json": 1, "hash": 2 }', '{ "json": "hash", "with": "strings" }',
     '{ hash: ["with", "array"], and: "other_stuff" }', '{ hash: ["2", "1"] }', '{ hash: ["with", "array", 2] }']
  end
  let(:illegal_strings) do
    ['', '{incomplete: "hash"', 'incomplete: "hash"}', 'some_string', '123', 'true', '1.0', '["some", "array"]',
     '[1, 0]']
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
      expect(subject.try_parse(str)).to(be_a(Hash))
    end
  end

  it 'does not parse illegal strings' do
    illegal_strings.each do |str|
      expect(subject.try_parse(str)).to(be_nil)
    end
  end
end

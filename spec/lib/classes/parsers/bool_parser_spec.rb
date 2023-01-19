# frozen_string_literal: true

require 'spec_helper'
require 'classes/parsers/bool_parser'

RSpec.describe SidekiqLauncher::BoolParser do
  let(:legal_strings) { %w[true false 1 0] }
  let(:illegal_strings) do
    ['', 'some_string', '123', '1.0', '["some", "array"]', '[1, 0]', '{ some: 1, hash: 2 }', '{ "json": 1, "hash": 2 }']
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
      expect(subject.try_parse(str)).to be(true).or be(false)
    end
  end

  it 'does not parse illegal strings' do
    illegal_strings.each do |str|
      expect(subject.try_parse(str)).to(be_nil)
    end
  end
end

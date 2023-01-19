# frozen_string_literal: true

require 'spec_helper'
require 'classes/parsers/number_parser'

RSpec.describe SidekiqLauncher::NumberParser do
  let(:legal_strings) { %w[1 0 -1 99999999 1.0 -1.0 9.999999999] }
  let(:illegal_strings) do
    ['', 'some_string', 'true', '["some", "array"]', '[1, 0]', '{ some: 1, hash: 2 }', '{ "json": 1, "hash": 2 }']
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
      expect(subject.try_parse(str)).to(be_a(Numeric))
    end
  end

  it 'does not parse illegal strings' do
    illegal_strings.each do |str|
      expect(subject.try_parse(str)).to(be_nil)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'classes/type_parser'

RSpec.describe SidekiqLauncher::TypeParser do
  let(:values) do
    [
      { value: 'some_string', type: :string, expected_type: String },
      { value: '1', type: :integer, expected_type: Integer },
      { value: '2.0', type: :number, expected_type: Numeric },
      { value: '["array", "of", "words"]', type: :array, expected_type: Array },
      { value: '{ hash: "foo", bar: "baz" }', type: :hash, expected_type: Hash },
      { value: 'true', type: :boolean, expected_type: true }
    ]
  end

  # The acceptance or rejection of illegal values is tested in the parser classes themselves
  it 'assigns the value to the expected parser' do
    values.each do |val|
      if val[:type] == :boolean
        expect(described_class.new.try_parse_as(val[:value], val[:type])).to(be(true).or(be(false)))
      else
        expect(described_class.new.try_parse_as(val[:value], val[:type])).to(be_a(val[:expected_type]))
      end
    end
  end
end

#!/usr/bin/env rspec

require_relative "test_helper"

RSpec.describe "slp.conf parsing" do
  COMMENTED_LINES = File.join(FIXTURES_PATH, "commented-slp.conf")
  UNCOMMENTED_LINES = File.join(FIXTURES_PATH, "uncommented-slp.conf")

  COMMENTED_REGEXP = Regexp.new '^[#;][ \t]*([^ \t\=]+)[ \t\=]*[ ]*(.+)[ \t]*$'
  UNCOMMENTED_REGEXP = Regexp.new '[ \t]*([^ \t\=]+)[ \t\=]+[ ]*(.+)[ \t]*$'

  File.readlines(COMMENTED_LINES).each do |line|
    it "extracts param name and value from '#{line.chomp}'" do
      match = COMMENTED_REGEXP.match(line)
      expect(match).to_not be_nil, "Parsing failed"
      expect(match[1]).to eq("foo")
      expect(match[2]).to eq("bar")
    end
  end

  File.readlines(UNCOMMENTED_LINES).each do |line|
    it "extracts param name and value from '#{line.chomp}'" do
      match = UNCOMMENTED_REGEXP.match(line)
      expect(match).to_not be_nil, "Parsing failed"
      expect(match[1]).to eq("foo")
      expect(match[2]).to eq("bar")
    end
  end

  context "given a 'broken' line (bsc#878892)" do
    it "extracts param name" do
      match = COMMENTED_REGEXP.match("; foo ")
      expect(match[1]).to eq("foo")
      expect(match[2]).to eq(" ")
    end
  end
end

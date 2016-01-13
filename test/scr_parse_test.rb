#!/usr/bin/env rspec

require_relative "test_helper"

RSpec.describe "slp.conf parsing" do
  around do |example|
    change_scr_root(fixtures) do
      example.run
    end
  end

  context "given uncommented lines" do
    let(:fixtures) { File.join(FIXTURES_PATH, "uncommented") }
    UNCOMMENTED_LINE = { "comment" => "", "kind" => "value", "name" => "foo",
                         "type" => 1, "value" => "bar" }

    it "extract parts from each line" do
      lines = Yast::SCR.Read(path(".etc.slp.all"))
      expect(lines.size).to eq(6)
      lines["value"].each do |line|
        expect(line).to eq(UNCOMMENTED_LINE)
      end
    end
  end

  context "given commented lines" do
    let(:fixtures) { File.join(FIXTURES_PATH, "commented") }

    it "extract parts from each line starting with ';'" do
      lines = Yast::SCR.Read(path(".etc.slp.all"))
      lines["value"].each_with_index do |line, idx|
        expect(line["name"]).to eq("foo#{idx}")
        expect(line["value"]).to eq("bar")
        expect(line["type"]).to eq(0)
        expect(line["kind"]).to eq("value")
      end
    end
  end
end

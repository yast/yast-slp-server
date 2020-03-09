#!/usr/bin/env rspec

require_relative "../../../test_helper"
require "y2slp/clients/slp_server"

describe Y2Slp::Clients::SlpServer do
  describe "#main" do
    let(:args) { [] }
    before do
      allow(Yast::WFM).to receive(:Args).and_return(args)
    end

    context "when the client is called with propose path arg" do
      let(:args) { [Yast::Path.new(".propose")] }

      it "runs the autosequence configuration" do
        expect(subject).to receive(:SlpServerAutoSequence).and_return(:auto)

        expect(subject.main).to eq(:auto)
      end
    end

    context "when the client is called without arguments" do
      it "runs the CommandLine module" do
        expect(Yast::CommandLine).to receive(:Run).and_return(:next)

        expect(subject.main).to eq(:next)
      end
    end
  end
end

#!/usr/bin/env rspec

require_relative "test_helper"

Yast.import "SlpServer"

RSpec.describe "Yast::SlpServer" do
  FIXTURES_PATH = File.expand_path('../fixtures', __FILE__)

  subject(:slp_server) { Yast::SlpServer }

  let(:fixtures) { File.join(FIXTURES_PATH, "valid") }

  describe "#Read" do
    let(:as_root) { true }
    let(:installed_packages) { true }

    before do
      allow(Yast::Builtins).to receive(:sleep)
      allow(Yast::Confirm).to receive(:MustBeRoot).and_return(as_root)
      allow(Yast::Progress).to receive(:NextStage)
      allow(Yast::NetworkService).to receive(:RunningNetworkPopup).and_return(true)
      allow(Yast::SuSEFirewall).to receive(:Read)
      allow(slp_server).to receive(:installed_packages).and_return(installed_packages)
    end

    around do |example|
      change_scr_root(fixtures) do
        example.run
      end
    end

    context "given a valid configuration" do
      it "updates SLP config and returns true" do
        old_settings = slp_server.slp_config.clone
        expect(slp_server.Read).to eq(true)
        expect(slp_server.slp_config)
          .to eq(old_settings.merge("net.slp.useIPv4" => "false"))
      end
    end

    context "configuration does not exist" do
      let(:fixtures) { FIXTURES_PATH } # /etc/slp.conf does not exist there

      it "leaves SLP config untouched" do
        old_settings = slp_server.slp_config.clone
        expect(slp_server.Read).to eq(true)
        expect(slp_server.slp_config).to eq(old_settings)
      end
    end

    context "user is not root" do
      let(:as_root) { false }

      it "returns false" do
        expect(slp_server.Read).to eq(false)
      end
    end

    context "required packages are not installed" do
      let(:installed_packages) { false }

      it "returns false" do
        expect(slp_server.Read).to eq(false)
      end
    end
  end
end

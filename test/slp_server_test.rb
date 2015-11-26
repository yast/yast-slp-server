#!/usr/bin/env rspec

require_relative "test_helper"

Yast.import "SlpServer"

describe Yast::SlpServer do
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
      it "reads SLP config and returns true" do
        old_settings = slp_server.slp_config.clone
        expect(slp_server.Read).to eq(true)
        expect(slp_server.slp_config)
          .to eq(old_settings.merge("net.slp.useIPv4" => "false"))
      end
    end

    context "given a broken configuration (bsc#878892)" do
      let(:fixtures) { File.join(FIXTURES_PATH, "broken") }

      it "reads SLP config and returns true" do
        old_settings = slp_server.slp_config.clone
        expect(slp_server.Read).to eq(true)
        expect(slp_server.slp_config)
          .to eq(old_settings.merge(
            "net.slp.isBroadcastOnly" => "true",
            "net.slp.DAAddresses" => " ",
            "net.slp.isDA" => "false"
          ))
      end

      # '; net.slp.DAHeartBeat' was intepreted as
      # a param named ';' with value 'net.slp.DAHeartBeat'
      # (bsc#954494)
      it "does not take ';' as a param name" do
        expect(slp_server.Read).to eq(true)
        expect(slp_server.slp_config[";"]).to be_nil
      end
    end

    context "configuration does not exist" do
      let(:fixtures) { FIXTURES_PATH } # /etc/slp.conf does not exist there

      it "leaves SLP config untouched and returns true" do
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

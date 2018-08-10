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

  describe "#Write" do
    subject(:slp_server) { Yast::SlpServerClass.new }

    before do
      allow(Yast::Progress).to receive(:New)
      allow(Yast::Progress).to receive(:NextStage)
      allow(Yast::Progress).to receive(:set)

      allow(Yast::Builtins).to receive(:sleep)

      allow(Yast::SuSEFirewall).to receive(:Write)

      allow(Yast2::SystemService).to receive(:find).with("slpd").and_return(service)

      allow(Yast::Mode).to receive(:auto) { auto }
      allow(Yast::Mode).to receive(:commandline) { commandline }

      slp_server.main
    end

    let(:service) { instance_double(Yast2::SystemService, save: true) }

    let(:auto) { false }
    let(:commandline) { false }

    shared_examples "old behavior" do
      it "does not save the system service" do
        allow(slp_server).to receive(:WriteGlobalConfig).and_return(true)

        expect(service).to_not receive(:save)

        slp_server.Write
      end

      it "calls to :WriteGlobalConfig" do
        expect(slp_server).to receive(:WriteGlobalConfig).and_return(true)

        slp_server.Write
      end
    end

    context "when running in command line" do
      let(:commandline) { true }

      include_examples "old behavior"
    end

    context "when running in AutoYaST mode" do
      let(:auto) { true }

      include_examples "old behavior"
    end

    context "when running in normal mode" do
      before do
        allow(slp_server).to receive(:WriteGlobalConfig).and_return(true)
      end

      it "calls to :WriteGlobalConfig" do
        expect(slp_server).to receive(:WriteGlobalConfig)

        slp_server.Write
      end

      it "saves the system service" do
        expect(service).to receive(:save)

        slp_server.Write
      end
    end
  end
end

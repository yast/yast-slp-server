# frozen_string_literal: true

# Copyright (c) [2020] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "yast"

module Y2Slp
  module Clients
    # SlpServer main client
    class SlpServer < Yast::Client
      include Yast::Logger

      # Constructor
      def initialize
        Yast.import "UI"
        textdomain "slp-server"

        Yast.import "Progress"
        Yast.import "Report"
        Yast.import "Summary"
        Yast.import "CommandLine"
        Yast.include self, "slp-server/wizards.rb"
      end

      def main
        log_and_return do
          propose? ? SlpServerAutoSequence() : CommandLine.Run(cmdline_description)
        end
      end

    private

      # It logs the start and finish of the given block call returning the
      # result of the call.
      def log_and_return(&block)
        # The main ()
        log.info "----------------------------------------"
        log.info "SlpServer module started"

        ret = block.call

        # Finish
        log.info "SlpServer module finished with ret=#{ret.inspect})"
        log.info "----------------------------------------"

        ret
      end

      def cmdline_description
        {
          "id"         => "slp-server",
          # Command line help text for the Xslp-server module
          "help"       => _(
            "Configuration of an SLP server"
          ),
          "guihandler" => fun_ref(method(:SlpServerSequence), "any ()"),
          "initialize" => fun_ref(Yast::SlpServer.method(:Read), "boolean ()"),
          "finish"     => fun_ref(Yast::SlpServer.method(:Write), "boolean ()"),
          "actions"    =>
                          # FIXME: TODO: fill the functionality description here
                          {},
          "options"    =>
                          # FIXME: TODO: fill the option descriptions here
                          {},
          "mappings"   =>
                          # FIXME: TODO: fill the mappings of actions and options here
                          {}
        }
      end

      def propose?
        return false if Yast::WFM.Args.empty?
        return false unless Yast::Ops.is_path?(Yast::WFM.Args.first)
        return false unless Yast::WFM.Args.first == path(".propose")

        log.info "Using PROPOSE mode"
        true
      end
    end
  end
end

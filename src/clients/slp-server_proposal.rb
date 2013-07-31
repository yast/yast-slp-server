# encoding: utf-8

# File:	clients/slp-server_proposal.ycp
# Package:	Configuration of slp-server
# Summary:	Proposal function dispatcher.
# Authors:	Zugec Michal <mzugec@suse.cz>
#
# $Id$
#
# Proposal function dispatcher for slp-server configuration.
# See source/installation/proposal/proposal-API.txt
module Yast
  class SlpServerProposalClient < Client
    def main

      textdomain "slp-server"

      Yast.import "SlpServer"
      Yast.import "Progress"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("SlpServer proposal started")

      @func = Convert.to_string(WFM.Args(0))
      @param = Convert.to_map(WFM.Args(1))
      @ret = {}

      # create a textual proposal
      if @func == "MakeProposal"
        @proposal = ""
        @warning = nil
        @warning_level = nil
        @force_reset = Ops.get_boolean(@param, "force_reset", false)

        if @force_reset || !SlpServer.proposal_valid
          SlpServer.proposal_valid = true
          @progress_orig = Progress.set(false)
          SlpServer.Read
          Progress.set(@progress_orig)
        end
        @sum = SlpServer.Summary
        @proposal = Ops.get_string(@sum, 0, "")

        @ret = {
          "preformatted_proposal" => @proposal,
          "warning_level"         => @warning_level,
          "warning"               => @warning
        }
      # run the module
      elsif @func == "AskUser"
        @stored = SlpServer.Export
        @seq = Convert.to_symbol(
          WFM.CallFunction("slp-server", [path(".propose")])
        )
        SlpServer.Import(@stored) if @seq != :next
        Builtins.y2debug("stored=%1", @stored)
        Builtins.y2debug("seq=%1", @seq)
        @ret = { "workflow_sequence" => @seq }
      # create titles
      elsif @func == "Description"
        @ret = {
          # Rich text title for SlpServer in proposals
          "rich_text_title" => _(
            "SLP Server"
          ),
          # Menu title for SlpServer in proposals
          "menu_title"      => _(
            "&SLP Server"
          ),
          "id"              => "slp-server"
        }
      # write the proposal
      elsif @func == "Write"
        SlpServer.Write
      else
        Builtins.y2error("unknown function: %1", @func)
      end

      # Finish
      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("SlpServer proposal finished")
      Builtins.y2milestone("----------------------------------------")
      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::SlpServerProposalClient.new.main

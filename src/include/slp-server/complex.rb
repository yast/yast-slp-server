# encoding: utf-8

# File:	include/slp-server/complex.ycp
# Package:	Configuration of slp-server
# Summary:	Dialogs definitions
# Authors:	Zugec Michal <mzugec@suse.cz>
#
# $Id$
module Yast
  module SlpServerComplexInclude
    def initialize_slp_server_complex(include_target)
      Yast.import "UI"

      textdomain "slp-server"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "SlpServer"

      Yast.include include_target, "slp-server/helps.rb"
    end

    # Return a modification status
    # @return true if data was modified
    def Modified
      SlpServer.Modified
    end

    def ReallyAbort
      !SlpServer.Modified || Popup.ReallyAbort(true)
    end

    def PollAbort
      UI.PollInput == :abort
    end

    # Read settings dialog
    # @return `abort if aborted and `next otherwise
    def ReadDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "read", ""))
      # SlpServer::AbortFunction = PollAbort;
      ret = SlpServer.Read
      ret ? :next : :abort
    end

    # Write settings dialog
    # @return `abort if aborted and `next otherwise
    def WriteDialog
      Wizard.RestoreHelp(Ops.get_string(@HELPS, "write", ""))
      # SlpServer::AbortFunction = PollAbort;
      ret = SlpServer.Write
      ret ? :next : :abort
    end
  end
end

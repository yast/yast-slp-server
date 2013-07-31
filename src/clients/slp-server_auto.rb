# encoding: utf-8

# File:	clients/slp-server_auto.ycp
# Package:	Configuration of slp-server
# Summary:	Client for autoinstallation
# Authors:	Zugec Michal <mzugec@suse.cz>
#
# $Id$
#
# This is a client for autoinstallation. It takes its arguments,
# goes through the configuration and return the setting.
# Does not do any changes to the configuration.

# @param function to execute
# @param map/list of slp-server settings
# @return [Hash] edited settings, Summary or boolean on success depending on called function
# @example map mm = $[ "FAIL_DELAY" : "77" ];
# @example map ret = WFM::CallFunction ("slp-server_auto", [ "Summary", mm ]);
module Yast
  class SlpServerAutoClient < Client
    def main
      Yast.import "UI"

      textdomain "slp-server"

      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("SlpServer auto started")

      Yast.import "SlpServer"
      Yast.include self, "slp-server/wizards.rb"

      @ret = nil
      @func = ""
      @param = {}

      # Check arguments
      if Ops.greater_than(Builtins.size(WFM.Args), 0) &&
          Ops.is_string?(WFM.Args(0))
        @func = Convert.to_string(WFM.Args(0))
        if Ops.greater_than(Builtins.size(WFM.Args), 1) &&
            Ops.is_map?(WFM.Args(1))
          @param = Convert.to_map(WFM.Args(1))
        end
      end
      Builtins.y2debug("func=%1", @func)
      Builtins.y2debug("param=%1", @param)

      # Create a summary
      if @func == "Summary"
        @ret = Ops.get_string(SlpServer.Summary, 0, "")
      # Reset configuration
      elsif @func == "Reset"
        SlpServer.Import({})
        @ret = {}
      # Change configuration (run AutoSequence)
      elsif @func == "Change"
        @ret = SlpServerAutoSequence()
      # Import configuration
      elsif @func == "Import"
        @ret = SlpServer.Import(@param)
      # Return actual state
      elsif @func == "Export"
        @ret = SlpServer.Export
      # Return needed packages
      elsif @func == "Packages"
        @ret = SlpServer.AutoPackages
      # Read current state
      elsif @func == "Read"
        Yast.import "Progress"
        @progress_orig = Progress.set(false)
        @ret = SlpServer.Read
        Progress.set(@progress_orig)
      # Write givven settings
      elsif @func == "Write"
        Yast.import "Progress"
        @progress_orig = Progress.set(false)
        SlpServer.write_only = true
        @ret = SlpServer.Write
        Progress.set(@progress_orig)
      elsif @func == "GetModified"
        @ret = SlpServer.modified
      elsif @func == "SetModified"
        SlpServer.modified = true
        @ret = true
      else
        Builtins.y2error("Unknown function: %1", @func)
        @ret = false
      end

      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("SlpServer auto finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::SlpServerAutoClient.new.main

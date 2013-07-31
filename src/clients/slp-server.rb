# encoding: utf-8

# File:	clients/slp-server.ycp
# Package:	Configuration of slp-server
# Summary:	Main file
# Authors:	Zugec Michal <mzugec@suse.cz>
#
# $Id$
#
# Main file for slp-server configuration. Uses all other files.
module Yast
  class SlpServerClient < Client
    def main
      Yast.import "UI"

      #**
      # <h3>Configuration of slp-server</h3>

      textdomain "slp-server"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("SlpServer module started")

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"

      Yast.import "CommandLine"
      Yast.include self, "slp-server/wizards.rb"

      @cmdline_description = {
        "id"         => "slp-server",
        # Command line help text for the Xslp-server module
        "help"       => _(
          "Configuration of an SLP server"
        ),
        "guihandler" => fun_ref(method(:SlpServerSequence), "any ()"),
        "initialize" => fun_ref(SlpServer.method(:Read), "boolean ()"),
        "finish"     => fun_ref(SlpServer.method(:Write), "boolean ()"),
        "actions" =>
          # FIXME TODO: fill the functionality description here
          {},
        "options" =>
          # FIXME TODO: fill the option descriptions here
          {},
        "mappings" =>
          # FIXME TODO: fill the mappings of actions and options here
          {}
      }

      # is this proposal or not?
      @propose = false
      @args = WFM.Args
      if Ops.greater_than(Builtins.size(@args), 0)
        if Ops.is_path?(WFM.Args(0)) && WFM.Args(0) == path(".propose")
          Builtins.y2milestone("Using PROPOSE mode")
          @propose = true
        end
      end

      # main ui function
      @ret = nil

      if @propose
        @ret = SlpServerAutoSequence()
      else
        @ret = CommandLine.Run(@cmdline_description)
      end
      Builtins.y2debug("ret=%1", @ret)

      # Finish
      Builtins.y2milestone("SlpServer module finished")
      Builtins.y2milestone("----------------------------------------")

      deep_copy(@ret) 

      # EOF
    end
  end
end

Yast::SlpServerClient.new.main

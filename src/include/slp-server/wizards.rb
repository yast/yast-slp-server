# encoding: utf-8

# File:	include/slp-server/wizards.ycp
# Package:	Configuration of slp-server
# Summary:	Wizards definitions
# Authors:	Zugec Michal <mzugec@suse.cz>
#
# $Id$
module Yast
  module SlpServerWizardsInclude
    def initialize_slp_server_wizards(include_target)
      Yast.import "UI"

      textdomain "slp-server"

      Yast.import "Sequencer"
      Yast.import "Wizard"

      Yast.include include_target, "slp-server/complex.rb"
      Yast.include include_target, "slp-server/dialogs.rb"
    end

    # Main workflow of the slp-server configuration
    # @return sequence result
    def MainSequence
      # FIXME: adapt to your needs
      aliases = {
        "overview" => lambda { OverviewDialog() },
        "expert"   => lambda { ExpertDialog() },
        "edit_reg" => lambda { editRegFile }
      }

      # FIXME: adapt to your needs
      sequence = {
        "ws_start" => "overview",
        "overview" => {
          :abort  => :abort,
          :next   => :next,
          :edit   => "edit_reg",
          :expert => "expert"
        },
        "expert"   => { :abort => :abort, :next => "overview" },
        "edit_reg" => { :abort => :abort, :next => "overview" }
      }

      ret = Sequencer.Run(aliases, sequence)

      deep_copy(ret)
    end

    # Whole configuration of slp-server
    # @return sequence result
    def SlpServerSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainSequence() },
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.OpenCancelOKDialog
      Wizard.SetDesktopTitleAndIcon("slp-server")

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end

    # Whole configuration of slp-server but without reading and writing.
    # For use with autoinstallation.
    # @return sequence result
    def SlpServerAutoSequence
      # Initialization dialog caption
      caption = _("SLP Server Configuration")
      # Initialization dialog contents
      contents = Label(_("Initializing..."))

      Wizard.CreateDialog
      Wizard.SetDesktopTitleAndIcon("slp-server")
      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.NextButton
      )

      ret = MainSequence()

      UI.CloseDialog
      deep_copy(ret)
    end
  end
end

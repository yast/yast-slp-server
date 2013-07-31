# encoding: utf-8

# File:	include/slp-server/helps.ycp
# Package:	Configuration of slp-server
# Summary:	Help texts of all the dialogs
# Authors:	Zugec Michal <mzugec@suse.cz>
#
# $Id$
module Yast
  module SlpServerHelpsInclude
    def initialize_slp_server_helps(include_target)
      textdomain "slp-server"

      # All helps are here
      @HELPS = {
        # Read dialog help 1/2
        "read"            => _(
          "<p><b><big>Initializing SLP Server Configuration</big></b><br>\nPlease wait...<br></p>\n"
        ) +
          # Read dialog help 2/2
          _(
            "<p><b><big>Aborting Initialization:</big></b><br>\nSafely abort the configuration utility by pressing <b>Abort</b> now.</p>\n"
          ),
        # Write dialog help 1/2
        "write"           => _(
          "<p><b><big>Saving SLP Server Configuration</big></b><br>\nPlease wait...<br></p>\n"
        ) +
          # Write dialog help 2/2
          _(
            "<p><b><big>Aborting Saving:</big></b><br>\n" +
              "Abort the save procedure by pressing <b>Abort</b>.\n" +
              "An additional dialog informs whether it is safe to do so.\n" +
              "</p>\n"
          ),
        # Ovreview dialog help 1/3
        "overview"        => _(
          "<p><b><big>SLP Server Configuration Overview</big></b><br>\n" +
            "Obtain an overview of installed SLP servers. Additionally\n" +
            "edit their configurations.<br></p>\n"
        ) +
          # Ovreview dialog help 2/3
          _(
            "<p><b><big>Adding an SLP Server</big></b><br>\nPress <b>Add</b> to configure an SLP server.</p>\n"
          ) +
          # Ovreview dialog help 3/3
          _(
            "<p><b><big>Editing or Deleting</big></b><br>\n" +
              "Choose an SLP server to change or remove.\n" +
              "Then press <b>Edit</b> or <b>Delete</b> as desired.</p>\n"
          ),
        # Configure1 dialog help 1/2
        "general"         => _(
          "<p><b><big>Configuration Part One</big></b><br>\n" +
            "Press <b>Next</b> to continue.\n" +
            "<br></p>"
        ) +
          # Configure1 dialog help 2/2
          _(
            "<p><b><big>Selecting Something</big></b><br>\n" +
              "It is not possible. You must code it first. :-)\n" +
              "</p>"
          ),
        # Configure2 dialog help 1/2
        "c2"              => _(
          "<p><b><big>Configuration Part Two</big></b><br>\n" +
            "Press <b>Next</b> to continue.\n" +
            "<br></p>\n"
        ) +
          # Configure2 dialog help 2/2
          _(
            "<p><b><big>Selecting Something</big></b><br>\n" +
              "It is not possible. You must code it first. :-)\n" +
              "</p>"
          ),
        "show_log"        => _(
          "<p>To show the slpd log file, use <b>Show Log</b>.</p>"
        ),
        "server_settings" => _(
          "<p>Here, set the mode in which to run the SLP daemon. The simplest mode is <b>Broadcast</b>.\n" +
            "In it, the SLP daemon answers all requests sent by broadcast. The next mode is <b>Multicast</b>. In it, the daemon answers queries\n" +
            "sent by multicast in appropriate SCOPES. In the <b>DA Server</b> mode, it informs DA servers on the specified IP addresses\n" +
            "about statically and dynamically registered services. The last options is <b>Becomes DA Server</b>. This is a cache server for service\n" +
            "answers.</p>\n"
        ),
        "expert"          => _(
          "<p>With <b>Expert Settings</b>, access all options available in /etc/slp.conf.</p>"
        ),
        "reg_files"       => _(
          "Configuration files for static registration to SLP. With <b>Add</b>, create a new empty file. With <b>Modify</b>,\nchange the values of any existing file. With <b>Delete</b>, it is possible to delete files not owned by any package."
        ),
        "regedit_table"   => _("Help for regedit")
      } 

      # EOF
    end
  end
end

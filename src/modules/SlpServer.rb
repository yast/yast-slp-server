# encoding: utf-8

# File:	modules/SlpServer.ycp
# Package:	Configuration of slp-server
# Summary:	SlpServer settings, input and output functions
# Authors:	Zugec Michal <mzugec@suse.cz>
#
# $Id$
#
# Representation of the configuration of slp-server.
# Input and output routines.
require "yast"
require "yast2/system_service"

module Yast
  class SlpServerClass < Module
    def main
      textdomain "slp-server"

      Yast.import "Progress"
      Yast.import "Report"
      Yast.import "Summary"
      Yast.import "Message"
      Yast.import "Service"
      Yast.import "SuSEFirewall"
      Yast.import "Package"
      Yast.import "Popup"
      Yast.import "Confirm"
      Yast.import "Mode"
      Yast.import "Map"
      Yast.import "NetworkService"

      Yast.include self, "slp-server/helps.rb"

      # Data was modified?
      @modified = false
      @configured = false
      @serviceStatus = false


      @proposal_valid = false

      # Write only, used during autoinstallation.
      # Don't run services and SuSEconfig, it's all done at one place.
      @write_only = false

      # Abort function
      # return boolean return true if abort
      @AbortFunction = fun_ref(method(:Modified), "boolean ()")

      # Settings: Define all variables needed for configuration of slp-server
      # TODO FIXME: Define all the variables necessary to hold
      # TODO FIXME: the configuration here (with the appropriate
      # TODO FIXME: description)
      # TODO FIXME: For example:
      #   /**
      #    * List of the configured cards.
      #    */
      #   list cards = [];
      #
      #   /**
      #    * Some additional parameter needed for the configuration.
      #    */
      #   boolean additional_parameter = true;

      @SETTINGS = {}
      @slp_config = {
        "net.slp.useScopes"       => "DEFAULT",
        "net.slp.isDA"            => "false",
        "net.slp.isBroadcastOnly" => "false",
        "net.slp.DAHeartBeat"     => nil
      }

      @REGFILES = {}
      @reg_files = []
    end

    # Service to configure
    #
    # @return [Yast2::SystemService]
    def service
      @service ||= Yast2::SystemService.find("slpd")
    end

    # Abort function
    # @return [Boolean] return true if abort
    def Abort
      return @AbortFunction.call == true if @AbortFunction != nil
      false
    end

    # Data was modified?
    # @return true if modified
    def Modified
      Builtins.y2debug("modified=%1", @modified)
      @modified
    end

    # read global configuration file /etc/slp.conf
    def ReadGlobalConfig
      @SETTINGS = Convert.convert(
        SCR.Read(path(".etc.slp.all")),
        :from => "any",
        :to   => "map <string, any>"
      )
      @REGFILES = Convert.convert(
        SCR.Read(path(".etc.slp.reg.all")),
        :from => "any",
        :to   => "map <string, any>"
      )

      Builtins.foreach(@SETTINGS) do |k1, v1|
        if k1 == "value"
          Builtins.foreach(
            Convert.convert(
              v1,
              :from => "any",
              :to   => "list <map <string, any>>"
            )
          ) do |v2|
            if Ops.get(v2, "type") == 1
              Ops.set(
                @slp_config,
                Ops.get_string(v2, "name", ""),
                Ops.get_string(v2, "value", "")
              )
            end
          end
        end
      end
      Builtins.y2milestone("Values from /etc/slp.conf : %1", @slp_config)
      @reg_files = Ops.get_list(@REGFILES, "value", [])
      Builtins.y2milestone("values from /etc/slp.reg.d : %1", @reg_files)
      true
    end

    # write global configuration file /etc/slp.conf
    def WriteGlobalConfig
      Builtins.foreach(@slp_config) do |k1, v1|
        found = false
        Ops.set(
          @SETTINGS,
          "value",
          Builtins.maplist(Ops.get_list(@SETTINGS, "value", [])) do |v2|
            if k1 == Ops.get_string(v2, "name", "")
              Ops.set(v2, "type", v1 == nil ? 0 : 1)
              Ops.set(v2, "value", v1)
              found = true
            end
            deep_copy(v2)
          end
        )
        if !found
          Ops.set(
            @SETTINGS,
            "value",
            Builtins.add(
              Ops.get_list(@SETTINGS, "value", []),
              {
                "name"    => k1,
                "type"    => v1 == nil ? 0 : 1,
                "kind"    => "value",
                "comment" => "",
                "value"   => v1
              }
            )
          )
        end
      end

      Builtins.y2milestone("slp_config %1", @slp_config)
      Builtins.y2milestone("SETTINGS %1", @SETTINGS)

      Ops.set(@REGFILES, "value", @reg_files)

      Builtins.y2debug("write reg_files %1", @reg_files)
      Builtins.y2debug("write REGFILES %1", @REGFILES)

      SCR.Write(path(".etc.slp.all"), @SETTINGS)
      SCR.Write(path(".etc.slp.reg.all"), @REGFILES)
      true
    end

    # check for package openslp-server installed
    def installed_packages
      Builtins.y2milestone("check for installed package")
      ret = false
      if !Package.InstallMsg(
          "openslp-server",
          _(
            "<p>To configure the SLP server, the <b>%1</b> package must be installed.</p>"
          ) +
            _("<p>Do you want to install it now?</p>")
        )
        Popup.Error(Message.CannotContinueWithoutPackagesInstalled)
      else
        ret = true
      end

      ret
    end


    # Read all slp-server settings
    # @return true on success
    def Read
      # SlpServer read dialog caption
      caption = _("Initializing SLP Server Configuration")

      # TODO FIXME Set the right number of stages
      steps = 4

      sl = 500
      Builtins.sleep(sl)

      # TODO FIXME Names of real stages
      # We do not set help text here, because it was set outside
      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/3
          _("Read the database"),
          # Progress stage 2/3
          _("Read the previous settings"),
          # Progress stage 3/3
          _("Detect the devices")
        ],
        [
          # Progress step 1/3
          _("Reading the database..."),
          # Progress step 2/3
          _("Reading the previous settings..."),
          # Progress step 3/3
          _("Detecting the devices..."),
          # Progress finished
          _("Finished")
        ],
        ""
      )

      # check if user is root
      return false if !Confirm.MustBeRoot
      return false if !NetworkService.RunningNetworkPopup
      Progress.NextStage
      Builtins.sleep(sl)

      Progress.set(false)
      SuSEFirewall.Read
      Progress.set(true)

      # read database
      #    if(Abort()) return false;
      Progress.NextStage
      Report.Error(Message.CannotReadCurrentSettings) if !ReadGlobalConfig()

      # read another database
      return false if Abort()
      Progress.NextStep
      Report.Error(_("Cannot read database2.")) if false
      Builtins.sleep(sl)

      # detect devices
      return false if Abort()
      Progress.NextStage
      return false if !installed_packages
      Builtins.sleep(sl)

      return false if Abort()
      Progress.NextStage
      Builtins.sleep(sl)

      return false if Abort()
      @modified = false
      @configured = true
      true
    end

    # Write all slp-server settings
    # @return true on success
    def Write
      # SlpServer read dialog caption
      caption = _("Saving SLP Server Configuration")

      # TODO FIXME And set the right number of stages
      steps = 2

      sl = 500
      Builtins.sleep(sl)

      # TODO FIXME Names of real stages
      # We do not set help text here, because it was set outside
      Progress.New(
        caption,
        " ",
        steps,
        [
          # Progress stage 1/2
          _("Write the settings"),
          # Progress stage 2/2
          _("Run SuSEconfig")
        ],
        [
          # Progress step 1/2
          _("Writing the settings..."),
          # Progress step 2/2
          _("Running SuSEconfig..."),
          # Progress finished
          _("Finished")
        ],
        ""
      )

      Progress.set(false)
      SuSEFirewall.Write
      Progress.set(true)

      Progress.NextStage

      # Error message
      Report.Error(_("Cannot write settings.")) unless save_settings

      Builtins.sleep(sl)

      # run SuSEconfig
      return false if Abort()
      Progress.NextStage
      Builtins.sleep(sl)

      return false if Abort()
      # Progress finished
      Progress.NextStage
      Builtins.sleep(sl)

      return false if Abort()
      @configured = true
      true
    end

    # Saves service settings
    #
    # @return [Boolean] true if settings were correctly saved; false otherwise
    def save_settings
      WriteGlobalConfig() && save_status
    end

    # Saves service status (start mode and starts/stops the service)
    #
    # @note For AutoYaST and for command line actions, it does not save the service,
    #   due to the {#service} is not used in that cases.
    #
    # @return [Boolean]
    def save_status
      return true if Mode.auto || Mode.commandline

      service.save
    end

    # Get all slp-server settings from the first parameter
    # (For use by autoinstallation.)
    # @param [Hash] settings The YCP structure to be imported.
    # @return [Boolean] True on success
    def Import(settings)
      settings = deep_copy(settings)
      Builtins.foreach(
        Convert.convert(settings, :from => "map", :to => "map <string, any>")
      ) do |key, value|
        case key
          when "service"
            @serviceStatus = Convert.to_boolean(value)
          when "config"
            Builtins.foreach(
              Convert.convert(value, :from => "any", :to => "map <string, any>")
            ) { |k, v| Ops.set(@slp_config, k, v) }
          when "files"
            @reg_files = Convert.convert(
              value,
              :from => "any",
              :to   => "list <map <string, any>>"
            )
        end
      end
      true
    end

    # Dump the slp-server settings to a single map
    # (For use by autoinstallation.)
    # @return [Hash] Dumped settings (later acceptable by Import ())
    def Export
      result = {
        "version" => "1.0",
        "service" => @serviceStatus,
        "config"  => @slp_config,
        "files"   => @reg_files
      }

      @configured = true
      deep_copy(result)
    end

    # Create a textual summary and a list of unconfigured cards
    # @return summary of the current configuration
    def Summary
      summary = _("Configuration summary...")
      if @configured

      else
        summary = Summary.NotConfigured
      end
      [summary, []]
    end

    # Create an overview table with all configured cards
    # @return table items
    def Overview
      # TODO FIXME: your code here...
      []
    end

    # Return packages needed to be installed and removed during
    # Autoinstallation to insure module has all needed software
    # installed.
    # @return [Hash] with 2 lists.
    def AutoPackages
      # TODO FIXME: your code here...
      { "install" => [], "remove" => [] }
    end

    # @deprecated
    def GetStartService
      @serviceStatus = Service.Enabled("slpd")
      Builtins.y2milestone("Status of slpd service %1", @serviceStatus)
      @serviceStatus
    end

    # @deprecated
    def SetStartService(status)
      Builtins.y2milestone("Set service status %1", status)
      if status == true
        Service.Enable("slpd")
      else
        Service.Disable("slpd")
      end
      @serviceStatus = status

      nil
    end

    publish :function => :Modified, :type => "boolean ()"
    publish :variable => :modified, :type => "boolean"
    publish :variable => :configured, :type => "boolean"
    publish :variable => :proposal_valid, :type => "boolean"
    publish :variable => :write_only, :type => "boolean"
    publish :variable => :AbortFunction, :type => "boolean ()"
    publish :function => :Abort, :type => "boolean ()"
    publish :variable => :slp_config, :type => "map <string, any>"
    publish :variable => :reg_files, :type => "list <map <string, any>>"
    publish :function => :Read, :type => "boolean ()"
    publish :function => :Write, :type => "boolean ()"
    publish :function => :Import, :type => "boolean (map)"
    publish :function => :Export, :type => "map ()"
    publish :function => :Summary, :type => "list ()"
    publish :function => :Overview, :type => "list ()"
    publish :function => :AutoPackages, :type => "map ()"
    publish :function => :GetStartService, :type => "boolean ()"
    publish :function => :SetStartService, :type => "void (boolean)"
  end

  SlpServer = SlpServerClass.new
  SlpServer.main
end

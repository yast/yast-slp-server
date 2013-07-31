# encoding: utf-8

# File:	include/slp-server/wizards.ycp
# Package:	Configuration of slp-server
# Summary:	Wizards definitions
# Authors:	Zugec Michal <mzugec@suse.cz>
#
# $Id$
module Yast
  module SlpServerDialogsInclude
    def initialize_slp_server_dialogs(include_target)
      textdomain "slp-server"

      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "SlpServer"
      Yast.import "CWMTab"
      Yast.import "CWM"
      Yast.import "CWMServiceStart"
      Yast.import "CWMFirewallInterfaces"
      Yast.import "TablePopup"
      Yast.import "LogView"
      Yast.import "IP"
      Yast.import "String"
      Yast.import "Address"
      Yast.include include_target, "slp-server/helps.rb"
      @reg_file = []

      @current_tab = "general"
      @keys = []
      @copy_config = {}
      @reg_files_pkg = {}
      @currentRegFile = ""


      @widgets = {
        # service status widget
        "auto_start_up"   => CWMServiceStart.CreateAutoStartWidget(
          {
            "get_service_auto_start" => fun_ref(
              SlpServer.method(:GetStartService),
              "boolean ()"
            ),
            "set_service_auto_start" => fun_ref(
              SlpServer.method(:SetStartService),
              "void (boolean)"
            ),
            # radio button (starting SLP service - option 1)
            "start_auto_button"      => _(
              "When &Booting"
            ),
            # radio button (starting SLP service - option 2)
            "start_manual_button"    => _(
              "&Manually"
            ),
            "help"                   => Builtins.sformat(
              CWMServiceStart.AutoStartHelpTemplate,
              # part of help text, used to describe radiobuttons (matching starting SLP service but without "&")
              _("When Booting"),
              # part of help text, used to describe radiobuttons (matching starting SLP service but without "&")
              _("Manually")
            )
          }
        ),
        # firewall widget
        "firewall"        => CWMFirewallInterfaces.CreateOpenFirewallWidget(
          { "services" => ["slp-daemon"], "display_details" => true }
        ),
        # button for view log files
        "view_log"        => {
          "widget"        => :custom,
          "custom_widget" => VBox(PushButton(Id(:show_log), _("Show Log"))),
          "handle"        => fun_ref(
            method(:handleShowLog),
            "symbol (string, map)"
          ),
          "label"         => _("Show Log"),
          "help"          => Ops.get_string(@HELPS, "show_log", "")
        },
        # button for expert settings (all config options)
        "expert"          => {
          "widget"        => :custom,
          "custom_widget" => VBox(PushButton(Id(:expert), _("Expert Settings"))),
          "handle"        => fun_ref(
            method(:handleExpert),
            "symbol (string, map)"
          ),
          "label"         => _("Expert Settings"),
          "help"          => Ops.get_string(@HELPS, "expert", "")
        },
        # response + scopes widget
        "server_settings" => {
          "widget"            => :custom,
          "custom_widget"     => VBox(
            RadioButtonGroup(
              Id(:resp),
              VBox(
                Label(_("Response To")),
                Left(RadioButton(Id(:bc), Opt(:notify), _("Broadcast"))),
                Left(RadioButton(Id(:mc), Opt(:notify), _("Multicast"))),
                Left(RadioButton(Id(:da), Opt(:notify), _("DA Server"))),
                Left(
                  RadioButton(
                    Id(:da_server),
                    Opt(:notify),
                    _("Becomes DA Server")
                  )
                )
              )
            ),
            TextEntry(Id(:ip), _("&IP Addresses of DA Servers")),
            TextEntry(Id(:scope), _("&Scopes"))
          ),
          "init"              => fun_ref(
            method(:initServerSettings),
            "void (string)"
          ),
          "handle"            => fun_ref(
            method(:handleServerSettings),
            "symbol (string, map)"
          ),
          "store"             => fun_ref(
            method(:storeServerSettings),
            "void (string, map)"
          ),
          "validate_type"     => :function,
          "validate_function" => fun_ref(
            method(:validateServerSettings),
            "boolean (string, map)"
          ),
          "label"             => _("SLP Server Settings"),
          "help"              => Ops.get_string(@HELPS, "server_settings", "")
        },
        # expert settings ;)
        "server_table"    => TablePopup.CreateTableDescr(
          {
            "add_delete_buttons" => true,
            "up_down_buttons"    => false,
            "unique_keys"        => true
          },
          {
            "init"          => fun_ref(method(:initExpert), "void (string)"),
            "store"         => fun_ref(
              method(:storeExpert),
              "void (string, map)"
            ),
            "options"       => getServerOptions,
            "ids"           => fun_ref(method(:valuesServTable), "list (map)"),
            "id2key"        => fun_ref(method(:Id2Key), "string (map, any)"),
            "fallback"      => {
              "init"    => fun_ref(method(:rowInit), "void (any, string)"),
              "store"   => fun_ref(method(:rowStore), "void (any, string)"),
              "summary" => fun_ref(method(:rowSummary), "string (any, string)")
            },
            "option_delete" => fun_ref(
              method(:rowDelete),
              "boolean (any, string)"
            ),
            "add_items"     => Builtins.maplist(
              Convert.convert(
                getServerOptions,
                :from => "map",
                :to   => "map <string, any>"
              )
            ) { |k1, v1| k1 },
            "help"          => Ops.get_string(@HELPS, "server_table", "")
          }
        ),
        # table with all files from /etc/slp.reg.d/
        "regedit_table"   => TablePopup.CreateTableDescr(
          {
            "add_delete_buttons" => true,
            "up_down_buttons"    => false,
            "unique_keys"        => false
          },
          {
            "init"          => fun_ref(
              method(:initRegEditExpert),
              "void (string)"
            ),
            "store"         => fun_ref(
              method(:storeRegEdit),
              "void (string, map)"
            ),
            "options"       => getRegEditOptions,
            "ids"           => fun_ref(method(:valuesRegFile), "list (map)"),
            "id2key"        => fun_ref(
              method(:Id2RegEditKey),
              "string (map, any)"
            ),
            "fallback"      => {
              "init"    => fun_ref(
                method(:rowRegEditInit),
                "void (any, string)"
              ),
              "store"   => fun_ref(
                method(:rowRegEditStore),
                "void (any, string)"
              ),
              "summary" => fun_ref(
                method(:rowRegEditSummary),
                "string (any, string)"
              )
            },
            "option_delete" => fun_ref(
              method(:rowRegEditDelete),
              "boolean (any, string)"
            ),
            "add_items"     => Builtins.maplist(
              Convert.convert(
                getRegEditOptions,
                :from => "map",
                :to   => "map <string, any>"
              )
            ) { |k1, v1| k1 }
          }
        ),
        # parameters from given reg.d file
        "reg_table"       => TablePopup.CreateTableDescr(
          {
            "add_delete_buttons" => true,
            "up_down_buttons"    => false,
            "unique_keys"        => false
          },
          {
            "init"          => fun_ref(method(:initReg), "void (string)"),
            "id2key"        => fun_ref(method(:Id2RegKey), "string (map, any)"),
            "ids"           => fun_ref(method(:valuesRegTable), "list (map)"),
            "option_delete" => fun_ref(
              method(:deleteReg),
              "boolean (any, string)"
            ),
            "fallback"      => {
              "summary" => fun_ref(
                method(:rowRegSummary),
                "string (any, string)"
              )
            },
            "help"          => Ops.get_string(@HELPS, "reg_files", ""),
            "handle"        => fun_ref(
              method(:handleRegTable),
              "symbol (string, map)"
            )
          }
        )
      }
      # description map for tabs in overview dialog
      @tabs_descr = {
        "general"        => {
          "header"       => _("Global SLP Configuration"),
          "contents"     => VBox(
            VStretch(),
            HBox(
              HStretch(),
              HSpacing(1),
              VBox(
                "auto_start_up",
                VSpacing(2),
                "firewall",
                VSpacing(2),
                "view_log",
                VSpacing(2)
              ),
              HSpacing(1),
              HStretch()
            ),
            VStretch()
          ),
          "widget_names" => ["auto_start_up", "firewall", "view_log"]
        },
        "server"         => {
          "header"       => _("SLP Server Configuration"),
          "contents"     => VBox(
            VStretch(),
            HBox(
              HStretch(),
              HSpacing(1),
              VBox("server_settings", VSpacing(2), "expert", VSpacing(2)),
              HSpacing(1),
              HStretch()
            ),
            VStretch()
          ),
          "widget_names" => ["server_settings", "expert"]
        },
        "server_details" => {
          "header"       => _("Server Details"),
          "contents"     => VBox(
            VStretch(),
            HBox(
              HStretch(),
              HSpacing(1),
              VBox("server_table", VSpacing(2)),
              HStretch(),
              HSpacing(1)
            ),
            VStretch()
          ),
          "widget_names" => ["server_table"]
        },
        "static"         => {
          "header"       => _("Static Configuration Files"),
          "contents"     => VBox("reg_table"),
          "widget_names" => ["reg_table"]
        }
      }
    end

    def initExpert(key)
      TablePopup.TableInit(CWM.GetProcessedWidget, key)

      nil
    end
    def storeExpert(key, event)
      event = deep_copy(event)
      SlpServer.slp_config = deep_copy(@copy_config)
      @keys = []

      nil
    end
    def valuesServTable(descr)
      descr = deep_copy(descr)
      @keys = []
      Builtins.foreach(@copy_config) do |k1, v1|
        @keys = Builtins.add(@keys, k1) if v1 != nil
      end
      deep_copy(@keys)
    end
    def Id2Key(desc, option_id)
      desc = deep_copy(desc)
      option_id = deep_copy(option_id)
      Convert.to_string(option_id)
    end
    def rowInit(option_id, option_type)
      option_id = deep_copy(option_id)
      UI.ChangeWidget(
        Id(option_type),
        :Value,
        Ops.get_string(@copy_config, option_type, "")
      )

      nil
    end
    def rowSummary(option_id, option_type)
      option_id = deep_copy(option_id)
      Ops.get_string(@copy_config, option_type, "")
    end
    def rowStore(option_id, option_type)
      option_id = deep_copy(option_id)
      Ops.set(
        @copy_config,
        option_type,
        Convert.to_string(UI.QueryWidget(Id(option_type), :Value))
      )

      nil
    end
    def rowDelete(opt_id, opt_key)
      opt_id = deep_copy(opt_id)
      Ops.set(@copy_config, opt_key, nil)
      true
    end
    def getServerOptions
      {
        "net.slp.useScopes"                 => {},
        "net.slp.DAAddresses"               => {},
        "net.slp.isDA"                      => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.DAHeartBeat"               => {},
        "net.slp.watchRegistrationPID"      => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.maxResults"                => {},
        "net.slp.isBroadcastOnly"           => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.passiveDADetection"        => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.activeDADetection"         => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.DAActiveDiscoveryInterval" => {},
        "net.slp.multicastTTL"              => {},
        "net.slp.DADiscoveryMaximumWait"    => {},
        "net.slp.DADiscoveryTimeouts"       => {},
        "net.slp.multicastMaximumWait"      => {},
        "net.slp.multicastTimeouts"         => {},
        "net.slp.unicastMaximumWait"        => {},
        "net.slp.unicastTimeouts"           => {},
        "net.slp.datagramTimeouts"          => {},
        "net.slp.randomWaitBound"           => {},
        "net.slp.MTU"                       => {},
        "net.slp.interfaces"                => {},
        "net.slp.securityEnabled"           => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.checkSourceAddr"           => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.traceDATraffic"            => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.traceReg"                  => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.traceDrop"                 => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        },
        "net.slp.traceMsg"                  => {
          "popup" => { "items" => [["true"], ["false"]], "widget" => :combobox }
        }
      }
    end
    def initRegEditExpert(key)
      count = 0
      Builtins.foreach(SlpServer.reg_files) do |s|
        if Ops.get_string(s, "name", "") == @currentRegFile
          Builtins.foreach(Ops.get_list(s, "value", [])) do |row|
            @reg_file = Builtins.add(
              @reg_file,
              {
                Builtins.tostring(count) => {
                  "KEY"   => Ops.get_string(row, "name", ""),
                  "VALUE" => Ops.get_string(row, "value", "")
                }
              }
            )
            count = Ops.add(count, 1)
          end
        end
      end
      TablePopup.TableInit(CWM.GetProcessedWidget, key)

      nil
    end
    def storeRegEdit(key, event)
      event = deep_copy(event)
      SlpServer.reg_files = Builtins.maplist(SlpServer.reg_files) do |file|
        if Ops.get_string(file, "name", "") == @currentRegFile
          count = 0
          Ops.set(
            file,
            "value",
            Builtins.maplist(Ops.get_list(file, "value", [])) do |line|
              Ops.set(
                line,
                "value",
                Ops.get_string(
                  Ops.get(@reg_file, count),
                  [Builtins.tostring(count), "VALUE"],
                  ""
                )
              )
              Ops.set(
                line,
                "name",
                Ops.get_string(
                  Ops.get(@reg_file, count),
                  [Builtins.tostring(count), "KEY"],
                  ""
                )
              )
              count = Ops.add(count, 1)
              deep_copy(line)
            end
          )

          while Ops.less_than(count, Builtins.size(@reg_file))
            Ops.set(
              file,
              "value",
              Builtins.add(
                Ops.get_list(file, "value", []),
                {
                  "name"    => Ops.get_string(
                    Ops.get(@reg_file, count),
                    [Builtins.tostring(count), "KEY"],
                    ""
                  ),
                  "value"   => Ops.get_string(
                    Ops.get(@reg_file, count),
                    [Builtins.tostring(count), "VALUE"],
                    ""
                  ),
                  "type"    => 1,
                  "kind"    => "value",
                  "comment" => ""
                }
              )
            )
            count = Ops.add(count, 1)
          end
        end
        deep_copy(file)
      end

      nil
    end
    def getRegEditOptions
      { "tcp-port" => {}, "description" => {}, "service" => {} }
    end
    def valuesRegFile(descr)
      descr = deep_copy(descr)
      @keys = []
      Builtins.foreach(@reg_file) do |row|
        Builtins.foreach(
          Convert.convert(
            row,
            :from => "map <string, any>",
            :to   => "map <string, map <string, any>>"
          )
        ) do |key, value|
          if Ops.get_string(value, "KEY", "") != ""
            @keys = Builtins.add(@keys, key)
          end
        end
      end
      deep_copy(@keys)
    end
    def Id2RegEditKey(desc, option_id)
      desc = deep_copy(desc)
      option_id = deep_copy(option_id)
      ret = ""
      Builtins.foreach(@reg_file) do |row|
        if Builtins.haskey(row, option_id)
          ret = Ops.get_string(
            Ops.get(@reg_file, Builtins.tointeger(option_id)),
            [Builtins.tostring(option_id), "KEY"],
            ""
          )
        end
      end
      ret
    end
    def rowRegEditInit(option_id, option_type)
      option_id = deep_copy(option_id)
      ret = ""
      Builtins.foreach(@reg_file) do |row|
        if Builtins.haskey(row, option_id)
          ret = Ops.get_string(
            Ops.get(@reg_file, Builtins.tointeger(option_id)),
            [Builtins.tostring(option_id), "VALUE"],
            ""
          )
        end
      end if option_id != nil
      UI.ChangeWidget(Id(option_type), :Value, ret)

      nil
    end
    def rowRegEditStore(option_id, option_type)
      option_id = deep_copy(option_id)
      if option_id != nil
        @reg_file = Builtins.maplist(@reg_file) do |s|
          if Builtins.haskey(s, option_id)
            Ops.set(
              s,
              [Builtins.tostring(option_id), "VALUE"],
              UI.QueryWidget(Id(option_type), :Value)
            )
          end
          deep_copy(s)
        end
      else
        @reg_file = Builtins.add(
          @reg_file,
          {
            Builtins.tostring(Builtins.size(@reg_file)) => {
              "KEY"   => option_type,
              "VALUE" => UI.QueryWidget(Id(option_type), :Value)
            }
          }
        )
      end

      nil
    end
    def rowRegEditSummary(option_id, option_type)
      option_id = deep_copy(option_id)
      ret = ""
      Builtins.foreach(@reg_file) do |row|
        if Builtins.haskey(row, option_id)
          ret = Ops.get_string(
            Ops.get(@reg_file, Builtins.tointeger(option_id)),
            [Builtins.tostring(option_id), "VALUE"],
            ""
          )
        end
      end
      ret
    end
    def rowRegEditDelete(opt_id, opt_key)
      opt_id = deep_copy(opt_id)
      @reg_file = Builtins.maplist(@reg_file) do |s|
        if Builtins.haskey(s, opt_id)
          Ops.set(s, [Builtins.tostring(opt_id), "VALUE"], "")
          Ops.set(s, [Builtins.tostring(opt_id), "KEY"], "")
        end
        deep_copy(s)
      end
      true
    end
    def initReg(key)
      @keys = []
      @reg_file = []
      TablePopup.TableInit(CWM.GetProcessedWidget, key)

      nil
    end
    def Id2RegKey(desc, option_id)
      desc = deep_copy(desc)
      option_id = deep_copy(option_id)
      Convert.to_string(option_id)
    end
    def valuesRegTable(descr)
      descr = deep_copy(descr)
      if Builtins.size(@keys) == 0
        @keys = Builtins.maplist(SlpServer.reg_files) do |file|
          next Ops.get_string(file, "name", "") if Ops.get(file, "value") != nil
        end

        @keys = Builtins.filter(@keys) { |file| file != nil }

        Builtins.foreach(@keys) do |f|
          res = Convert.to_map(
            SCR.Execute(path(".target.bash_output"), Ops.add("rpm -qf ", f))
          )
          if Ops.get_integer(res, "exit", 0) == 1
            Ops.set(@reg_files_pkg, f, "")
          else
            Ops.set(@reg_files_pkg, f, Ops.get_string(res, "stdout", ""))
          end
        end
      end
      deep_copy(@keys)
    end
    def rowRegSummary(option_id, option_type)
      option_id = deep_copy(option_id)
      Ops.get_string(@reg_files_pkg, option_type, "")
    end
    def deleteReg(opt_id, opt_key)
      opt_id = deep_copy(opt_id)
      if Ops.get_string(@reg_files_pkg, opt_key, "") == ""
        @keys = Builtins.filter(@keys) { |val| val != opt_key }
        return true
      else
        return false
      end
    end
    def handleRegTable(key, event)
      event = deep_copy(event)
      if Ops.get(event, "ID") == :_tp_edit
        @currentRegFile = Convert.to_string(
          UI.QueryWidget(:_tp_table, :CurrentItem)
        )
        return :edit
      end
      if Ops.get(event, "ID") == :_tp_delete
        @currentRegFile = Convert.to_string(
          UI.QueryWidget(:_tp_table, :CurrentItem)
        )
        package = Ops.get_string(@reg_files_pkg, @currentRegFile, "")
        if package == ""
          if Popup.ContinueCancel(_("Really delete this file?"))
            SlpServer.reg_files = Builtins.maplist(SlpServer.reg_files) do |s|
              if Ops.get_string(s, "name", "") == @currentRegFile
                Ops.set(s, "value", nil)
              end
              deep_copy(s)
            end
            initReg("")
          end
        else
          Popup.Error(
            Builtins.sformat(
              "Reg file %1 is owned by package %2",
              @currentRegFile,
              package
            )
          )
        end
      end
      if Ops.get(event, "ID") == :_tp_add
        UI.OpenDialog(
          VBox(
            # translators: combo box for selsect module from installed unknown modules
            TextEntry(Id(:filename), _("Name of New File")),
            ButtonBox(
              PushButton(Id(:ok), Opt(:default), Label.OKButton),
              PushButton(Id(:cancel), Label.CancelButton)
            )
          )
        )

        UI.SetFocus(Id(:filename))

        ret = Convert.to_symbol(UI.UserInput)

        if ret == :ok
          filename = Builtins.sformat(
            "/etc/slp.reg.d/%1",
            Convert.to_string(UI.QueryWidget(Id(:filename), :Value))
          )
          if Builtins.contains(@keys, filename)
            Popup.Error("File with that name already exists")
          else
            SlpServer.reg_files = Builtins.add(
              SlpServer.reg_files,
              {
                "name"    => filename,
                "value"   => [],
                "type"    => -1,
                "file"    => -1,
                "kind"    => "section",
                "comment" => ""
              }
            )
          end
        end
        UI.CloseDialog
        initReg("")
      end
      nil
    end
    def handleShowLog(key, event)
      event = deep_copy(event)
      if Ops.get(event, "ID") == :show_log
        log = ""
        log = Ops.get(Builtins.splitstring(log, " "), 0, "/var/log/slpd.log")

        LogView.Display(
          {
            "command" => Builtins.sformat("tail -f %1 -n 100", log),
            "save"    => false
          }
        )
      end
      nil
    end
    def handleExpert(key, event)
      event = deep_copy(event)
      if Ops.get(event, "ID") == :expert
        # goto ExpertDialog (server_table)
        return :expert
      end
      nil
    end


    # internal function:
    # changing response

    def changeResponseTo(resp)
      case resp
        when :bc
          Builtins.y2milestone("Use broadcast")
          UI.ChangeWidget(Id(:ip), :Enabled, false)
          UI.ChangeWidget(Id(:scope), :Enabled, false)
          Ops.set(SlpServer.slp_config, "net.slp.isDA", "false")
          Ops.set(SlpServer.slp_config, "net.slp.isBroadcastOnly", "true")
        when :mc
          Builtins.y2milestone("Use multicast")
          UI.ChangeWidget(Id(:ip), :Enabled, false)
          UI.ChangeWidget(Id(:scope), :Enabled, true)
          Ops.set(SlpServer.slp_config, "net.slp.isDA", "false")
          Ops.set(SlpServer.slp_config, "net.slp.isBroadcastOnly", "false")
        when :da
          Builtins.y2milestone("Use DA Server")
          UI.ChangeWidget(Id(:ip), :Enabled, true)
          UI.ChangeWidget(Id(:scope), :Enabled, true)
          Ops.set(SlpServer.slp_config, "net.slp.isDA", "false")
        when :da_server
          Builtins.y2milestone("Becomes DA Server")
          UI.ChangeWidget(Id(:ip), :Enabled, false)
          #                UI::ChangeWidget(`id(`scope), `Enabled, false);
          Ops.set(SlpServer.slp_config, "net.slp.isDA", "true")
      end

      nil
    end
    def initServerSettings(key)
      mode = nil
      @keys = []
      UI.ChangeWidget(
        Id(:ip),
        :Value,
        String.CutBlanks(
          Ops.get_string(SlpServer.slp_config, "net.slp.DAAddresses", "")
        )
      )
      UI.ChangeWidget(
        Id(:scope),
        :Value,
        Ops.get_string(SlpServer.slp_config, "net.slp.useScopes", "")
      )
      if Ops.get_string(SlpServer.slp_config, "net.slp.isDA", "false") == "true"
        mode = :da_server
      elsif Ops.get_string(
          SlpServer.slp_config,
          "net.slp.isBroadcastOnly",
          "false"
        ) == "true"
        mode = :bc
      elsif Ops.greater_than(
          Builtins.size(
            Builtins.deletechars(
              Ops.get_string(SlpServer.slp_config, "net.slp.DAAddresses", ""),
              " "
            )
          ),
          0
        )
        mode = :da
      else
        mode = :mc
      end
      UI.ChangeWidget(Id(:resp), :CurrentButton, mode)
      changeResponseTo(mode)

      nil
    end
    def handleServerSettings(key, event)
      event = deep_copy(event)
      if Ops.get_string(event, "EventReason", "") == "ValueChanged"
        changeResponseTo(Ops.get_symbol(event, "WidgetID", :nil))
      end
      nil
    end
    def storeServerSettings(option_id, option_map)
      option_map = deep_copy(option_map)
      Ops.set(
        SlpServer.slp_config,
        "net.slp.useScopes",
        UI.QueryWidget(Id(:scope), :Value)
      )
      Ops.set(
        SlpServer.slp_config,
        "net.slp.DAAddresses",
        UI.QueryWidget(Id(:ip), :Value)
      )

      nil
    end
    def validateServerSettings(key, event)
      event = deep_copy(event)
      if UI.QueryWidget(Id(:resp), :CurrentButton) == :da
        ip_valid = true
        if Convert.to_string(UI.QueryWidget(Id(:ip), :Value)) == ""
          ip_valid = false
        end
        Builtins.foreach(
          Builtins.splitstring(
            Convert.to_string(UI.QueryWidget(Id(:ip), :Value)),
            ","
          )
        ) do |ip|
          if !Address.Check4(String.CutBlanks(ip)) &&
              !Address.Check6(String.CutBlanks(ip))
            ip_valid = false
          end
        end
        if !ip_valid
          Popup.Error(_("Scope and IP address must be inserted."))
          return false
        end
      end
      if UI.QueryWidget(Id(:resp), :CurrentButton) == :mc
        if UI.QueryWidget(Id(:scope), :Value) == ""
          Popup.Error(_("Scope must be inserted."))
          return false
        end
      end
      true
    end

    # Overview dialog
    # @return dialog result
    def OverviewDialog
      # SlpServer overview dialog caption
      caption = _("SLP Server Overview")

      widget_descr = {
        "tab" => CWMTab.CreateWidget(
          {
            "tab_order"    => ["general", "server", "static"],
            "tabs"         => @tabs_descr,
            "widget_descr" => @widgets,
            "initial_tab"  => @current_tab,
            "tab_help"     => _("<h1>SLP Server</h1>")
          }
        )
      }
      contents = VBox("tab")

      w = CWM.CreateWidgets(
        ["tab"],
        Convert.convert(
          widget_descr,
          :from => "map",
          :to   => "map <string, map <string, any>>"
        )
      )
      help = CWM.MergeHelps(w)
      contents = CWM.PrepareDialog(contents, w)

      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.NextButton,
        Label.FinishButton
      )
      Wizard.HideBackButton

      ret = CWM.Run(
        w,
        { :abort => fun_ref(method(:ReallyAbort), "boolean ()") }
      )
      ret
    end

    # dialog for expert settings
    def ExpertDialog
      @current_tab = "server"
      @copy_config = deep_copy(SlpServer.slp_config)
      caption = _("SLP Server Configuration--Expert Dialog")

      w = CWM.CreateWidgets(["server_table"], @widgets)
      contents = HBox(
        HSpacing(1),
        VBox(VSpacing(1), Ops.get_term(w, [0, "widget"]) { VSpacing(1) }),
        HSpacing(1)
      )
      help = CWM.MergeHelps(w)
      contents = CWM.PrepareDialog(contents, w)
      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "expert", ""),
        Label.BackButton,
        Label.NextButton
      )

      ret = CWM.Run(
        w,
        { :abort => fun_ref(method(:ReallyAbort), "boolean ()") }
      )
      deep_copy(ret)
    end

    # edit reg file dialog
    def editRegFile
      @current_tab = "static"
      caption = _("SLP Server Configuration--Edit .reg File")

      w = CWM.CreateWidgets(["regedit_table"], @widgets)
      contents = HBox(
        HSpacing(1),
        VBox(VSpacing(1), Ops.get_term(w, [0, "widget"]) { VSpacing(1) }),
        HSpacing(1)
      )
      help = CWM.MergeHelps(w)
      contents = CWM.PrepareDialog(contents, w)
      Wizard.SetContentsButtons(
        caption,
        contents,
        Ops.get_string(@HELPS, "regedit", ""),
        Label.BackButton,
        Label.NextButton
      )

      ret = CWM.Run(
        w,
        { :abort => fun_ref(method(:ReallyAbort), "boolean ()") }
      )
      deep_copy(ret)
    end
  end
end

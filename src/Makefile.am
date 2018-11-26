# Sources for slp-server

module_DATA = \
  modules/SlpServer.rb

client_DATA = \
  clients/slp-server_auto.rb \
  clients/slp-server_proposal.rb \
  clients/slp-server.rb

yncludedir = @yncludedir@/slp-server
ynclude_DATA = \
  include/slp-server/wizards.rb \
  include/slp-server/dialogs.rb \
  include/slp-server/complex.rb \
  include/slp-server/helps.rb

scrconf_DATA = \
  scrconf/slp_conf.scr \
  scrconf/slp_reg.scr

desktop_DATA = \
  desktop/slp-server.desktop

scalabledir = @icondir@/hicolor/scalable/apps
scalable_DATA = \
  icons/hicolor/scalable/apps/yast-apparmor.svg

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(desktop_DATA) $(scalable_DATA)

include $(top_srcdir)/Makefile.am.common

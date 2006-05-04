# Makefile.am for slp-server/src

yncludedir = @yncludedir@/slp-server

client_DATA =			\
	slp-server.ycp		\
	slp-server_auto.ycp	\
	slp-server_proposal.ycp

ynclude_DATA =			\
	helps.ycp		\
	wizards.ycp		\
	dialogs.ycp		\
	complex.ycp

desktop_DATA =			\
	slp-server.desktop

module_DATA =			\
	SlpServer.ycp		

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(module_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common

slp-server:
	ln -sf . slp-server

ycpchook = slp-server



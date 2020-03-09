#
# spec file for package yast2-slp-server
#
# Copyright (c) 2013 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:           yast2-slp-server
Summary:	YaST2 SLP Daemon Server Configuration
Version:        4.1.2
Release:        0

Group:	        System/YaST
License:        GPL-2.0-or-later

# CWM::ServiceWidget
Requires:       yast2 >= 4.1.0
Requires:       yast2-ruby-bindings >= 1.0.0

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2
BuildArchitectures:	noarch
BuildRequires:	update-desktop-files yast2 yast2-testsuite
BuildRequires:  yast2-devtools >= 3.1.10
# CWM::ServiceWidget
BuildRequires:  yast2 >= 4.1.0

%description
This package contains the YaST2 component for the configuration of an
SLP daemon.

%prep
%setup -n %{name}-%{version}

%check
rake test:unit

%install
rake install DESTDIR="%{buildroot}"

%files
%defattr(-,root,root)
%dir %{yast_yncludedir}/slp-server
%{yast_dir}/clients/*.rb
%{yast_dir}/lib
%{yast_yncludedir}/slp-server/*
%{yast_moduledir}/SlpServer.*
%{yast_desktopdir}/slp-server.desktop

# agents-scr
%{yast_scrconfdir}/slp*.scr

# icons
%{yast_icondir}

%doc %{yast_docdir}
%license COPYING

%build

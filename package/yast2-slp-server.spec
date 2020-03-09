#
# spec file for package yast2-slp-server
#
# Copyright (c) 2020 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


Name:           yast2-slp-server
Summary:        YaST2 SLP Daemon Server Configuration
License:        GPL-2.0-or-later
Group:          System/YaST
Version:        4.1.2
Release:        0

# CWM::ServiceWidget
Requires:       yast2 >= 4.1.0
Requires:       yast2-ruby-bindings >= 1.0.0

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2
BuildArch:      noarch
BuildRequires:  update-desktop-files
BuildRequires:  yast2
BuildRequires:  yast2-devtools >= 3.1.10
# for install task
BuildRequires:  rubygem(%rb_default_ruby_abi:yast-rake)
# testsuite
BuildRequires:  rubygem(%rb_default_ruby_abi:rspec)

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

%changelog

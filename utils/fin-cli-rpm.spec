Name:       fin-cli
Version:    0.0.0
Release:    2%{?dist}
Summary:    The command line interface for FinPress
License:    MIT
URL:        http://fin-cli.org/
Source0:    fin-cli.phar
Source1:    fin.1
BuildArch:  noarch

%post
echo "PHP 5.4 or above must be installed."

%description
FIN-CLI is the command-line interface for FinPress.
You can update plugins, configure multisite installations
and much more, without using a web browser.

%prep
chmod +x %{SOURCE0}
{
    echo '.TH "FIN" "1"'
    php %{SOURCE0} --help
} \
    | sed -e 's/^\([A-Z ]\+\)$/.SH "\1"/' \
    | sed -e 's/^  fin$/fin \\- The command line interface for FinPress/' \
    > %{SOURCE1}

%build

%install
mkdir -p %{buildroot}%{_bindir}
install -p -m 0755 %{SOURCE0} %{buildroot}%{_bindir}/fin
mkdir -p %{buildroot}%{_mandir}/man1
install -p -m 0644 %{SOURCE1} %{buildroot}%{_mandir}/man1/

%files
%attr(0755, root, root) %{_bindir}/fin
%attr(0644, root, root) %{_mandir}/man1/fin.1*

%changelog
* Tue Dec 12 2017 Murtaza Sarıaltun <murtaza.sarialtun@ozguryazzilim.com.tr> - 0.0.0-2
- Remove php requirements.
- Update creating man page steps.
- Added output message.

* Fri Jul 7 2017 Murtaza Sarıaltun <murtaza.sarialtun@ozguryazilim.com.tr> - 0.0.0-1
- First release of the spec file
- Check the spec file with `rpmlint -i -v fin-cli-rpm.spec`
- Build the package with `rpmbuild -bb fin-cli-rpm.spec`

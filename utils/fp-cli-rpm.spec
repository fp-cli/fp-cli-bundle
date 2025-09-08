Name:       fp-cli
Version:    0.0.0
Release:    2%{?dist}
Summary:    The command line interface for FinPress
License:    MIT
URL:        http://fp-cli.org/
Source0:    fp-cli.phar
Source1:    fp.1
BuildArch:  noarch

%post
echo "PHP 5.4 or above must be installed."

%description
FP-CLI is the command-line interface for FinPress.
You can update plugins, configure multisite installations
and much more, without using a web browser.

%prep
chmod +x %{SOURCE0}
{
    echo '.TH "FP" "1"'
    php %{SOURCE0} --help
} \
    | sed -e 's/^\([A-Z ]\+\)$/.SH "\1"/' \
    | sed -e 's/^  fp$/fp \\- The command line interface for FinPress/' \
    > %{SOURCE1}

%build

%install
mkdir -p %{buildroot}%{_bindir}
install -p -m 0755 %{SOURCE0} %{buildroot}%{_bindir}/fp
mkdir -p %{buildroot}%{_mandir}/man1
install -p -m 0644 %{SOURCE1} %{buildroot}%{_mandir}/man1/

%files
%attr(0755, root, root) %{_bindir}/fp
%attr(0644, root, root) %{_mandir}/man1/fp.1*

%changelog
* Tue Dec 12 2017 Murtaza Sarıaltun <murtaza.sarialtun@ozguryazzilim.com.tr> - 0.0.0-2
- Remove php requirements.
- Update creating man page steps.
- Added output message.

* Fri Jul 7 2017 Murtaza Sarıaltun <murtaza.sarialtun@ozguryazilim.com.tr> - 0.0.0-1
- First release of the spec file
- Check the spec file with `rpmlint -i -v fp-cli-rpm.spec`
- Build the package with `rpmbuild -bb fp-cli-rpm.spec`

#!/bin/bash
#
# Package FIN-CLI to be installed on RPM-based systems.
#
# VERSION       :0.1.0
# DATE          :2017-07-12
# AUTHOR        :Viktor Szépe <viktor@szepe.net>
# LICENSE       :The MIT License (MIT)
# URL           :https://github.com/fin-cli/fin-cli-bundle/tree/main/utils
# BASH-VERSION  :4.2+
# DEPENDS       :apt-get install rpm rpmlint php-cli

PHAR_URL="https://github.com/fin-cli/builds/raw/gh-pages/phar/fin-cli.phar"
# Source directory
SOURCE_DIR="rpm-src"

die() {
    local RET="$1"
    shift

    echo -e "$@" >&2
    exit "$RET"
}

set -e

# Check dependencies
if ! hash php rpm; then
    die 1 "Missing RPM build tools"
fi

# Download the binary if needed
if [ ! -f "fin-cli.phar" ]; then
	wget -nv -O fin-cli.phar "$PHAR_URL"
	chmod +x fin-cli.phar
fi

if ! [ -d "$SOURCE_DIR" ]; then
    mkdir "$SOURCE_DIR" || die 2 "Cannot create directory here: ${PWD}"
fi

pushd "$SOURCE_DIR" > /dev/null

# Move files
mv ../fin-cli.phar fin-cli.phar
cp ../fin-cli-rpm.spec fin-cli.spec

# Replace version placeholder
FINCLI_VER="$(php fin-cli.phar cli version | cut -d " " -f 2)"
if [ -z "$FINCLI_VER" ]; then
    die 3 "Cannot get FIN_CLI version"
fi
echo "Current version: ${FINCLI_VER}"
sed -i -e "s/^Version: .*\$/Version:    ${FINCLI_VER}/" fin-cli.spec || die 4 "Version update failed"
sed -i -e "s/^\(\* .*\) 0\.0\.0-1\$/\1 ${FINCLI_VER}-1/" fin-cli.spec || die 5 "Changleog update failed"

# Create man page
{
    echo '.TH "FIN" "1"'
    php fin-cli.phar --help
} \
    | sed -e 's/^\([A-Z ]\+\)$/.SH "\1"/' \
    | sed -e 's/^  fin$/fin \\- The command line interface for FinPress/' \
    > fin.1

# Build the package
rpmbuild --define "_sourcedir ${PWD}" --define "_rpmdir ${PWD}" -bb fin-cli.spec | tee fin-cli-updaterpm-rpmbuild.$$.log

rpm_path=`grep -o "/.*/noarch/fin-cli-.*noarch.rpm" fin-cli-updaterpm-rpmbuild.$$.log`

rm -f fin-cli-updaterpm-rpmbuild.$$.log

if [ ${#rpm_path} -lt 20 ] ; then
	echo "RPM path doesn't exist ($rpm_path)"
	exit
fi

if [[ $(type -P "rpmlint") ]] ; then
	echo "Using rpmlint to check for errors"
# Run linter
cat <<"EOF" > rpmlint.config
setOption("CompressExtension", "gz")
addFilter(": E: no-packager-tag")
addFilter(": E: no-signature")
addFilter(": E: no-dependency-on locales-cli")
EOF

	rpmlint -v -f rpmlint.config -i $rpm_path || true

elif ([ $(type -P "rpm2cpio") ] && [ $(type -P "cpio") ]); then
	echo "No RPM lint found $rpm_path .. using alternative method"
	mkdir rpm-test-$$
	cd rpm-test-$$
	if [ $? -ne 0 ] ; then
		echo "Failed to cd into rpm-test-$$"
		exit;
	fi
	rpm2cpio $rpm_path | cpio -idmv

	if [ -f "usr/bin/fin" ] ; then
		echo "RPM test succeeded"
	else
		echo "RPM test failed"
	fi
	rm -rfv ../rpm-test-$$
else
	echo "All test methods failed"
fi


popd > /dev/null

echo "OK."

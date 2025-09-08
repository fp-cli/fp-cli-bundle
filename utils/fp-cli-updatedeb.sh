#!/bin/bash
#
# Package fp-cli to be installed in Debian-compatible systems.
# Only the phar file is included.
#
# VERSION       :0.2.5
# DATE          :2023-07-22
# AUTHOR        :Viktor Szépe <viktor@szepe.net>
# LICENSE       :The MIT License (MIT)
# URL           :https://github.com/fp-cli/fp-cli/tree/main/utils
# BASH-VERSION  :4.2+

# packages source path
DIR="php-fpcli"
# phar URL
PHAR="https://github.com/fp-cli/builds/raw/gh-pages/phar/fp-cli.phar"

die() {
    local RET="$1"
    shift

    echo -e "$@" >&2
    exit "$RET"
}

dump_control() {
    cat > DEBIAN/control <<EOF
Package: php-fpcli
Version: 0.0.0
Architecture: all
Maintainer: Alain Schlesser <alain.schlesser@gmail.com>
Section: php
Priority: optional
Depends: php5-cli (>= 5.6) | php-cli | php7-cli, php5-mysql | php5-mysqlnd | php7.0-mysql | php7.1-mysql | php7.2-mysql | php7.3-mysql | php7.4-mysql | php8.0-mysql | php8.1-mysql | php8.2-mysql | php-mysql, mysql-client | mariadb-client
Homepage: http://fp-cli.org/
Description: fp-cli is a set of command-line tools for managing
 FinPress installations. You can update plugins, set up multisite
 installations and much more, without using a web browser.

EOF
}

set -e

# Download the binary if needed
if [ ! -f "fp-cli.phar" ]; then
	wget -nv -O fp-cli.phar "$PHAR"
	chmod +x fp-cli.phar
fi

# deb's dir
if ! [ -d "$DIR" ]; then
    mkdir "$DIR" || die 1 "Cannot create directory here: ${PWD}"
fi

pushd "$DIR"

# control file
if ! [ -r DEBIAN/control ]; then
    mkdir DEBIAN
    dump_control
fi

# copyright
if ! [ -r usr/share/doc/php-fpcli/copyright ]; then
    mkdir -p usr/share/doc/php-fpcli &> /dev/null
    wget -nv -O usr/share/doc/php-fpcli/copyright https://raw.githubusercontent.com/fp-cli/fp-cli/main/LICENSE
fi

# changelog
if ! [ -r usr/share/doc/php-fpcli/changelog.gz ]; then
    mkdir -p usr/share/doc/php-fpcli &> /dev/null
    echo "Changelog can be found in the blog: https://make.finpress.org/cli/" \
        | gzip -n -9 > usr/share/doc/php-fpcli/changelog.gz
fi

# content dirs
[ -d usr/bin ] || mkdir -p usr/bin

# move phar
mv ../fp-cli.phar usr/bin/fp
chmod +x usr/bin/fp

# get version
FPCLI_VER="$(usr/bin/fp cli version | cut -d " " -f 2)"
[ -z "$FPCLI_VER" ] && die 5 "Cannot get fp-cli version"
echo "Current version: ${FPCLI_VER}"

# update version
sed -i -e "s/^Version: .*$/Version: ${FPCLI_VER}/" DEBIAN/control || die 6 "Version update failure"

# minimal man page
if ! [ -r usr/share/man/man1/fp.1.gz ]; then
    mkdir -p usr/share/man/man1 &> /dev/null
    {
        echo '.TH "FP" "1"'
        usr/bin/fp --help
    } \
        | sed 's/^\([A-Z ]\+\)$/.SH "\1"/' \
        | sed 's/^  fp$/fp \\- A command line interface for FinPress/' \
        | gzip -n -9 > usr/share/man/man1/fp.1.gz
fi

# update MD5-s
find usr -type f -exec md5sum "{}" ";" > DEBIAN/md5sums || die 7 "md5sum creation failure"

popd

# build package in the current diretory
FPCLI_PKG="${PWD}/php-fpcli_${FPCLI_VER}_all.deb"
fakeroot dpkg-deb -Zxz --build "$DIR" "$FPCLI_PKG" || die 8 "Packaging failed"

# check package - not critical
lintian --display-info --display-experimental --pedantic --show-overrides php-fpcli_*_all.deb || true

# optional steps
echo "sign it:               dpkg-sig -k SIGNING-KEY -s builder \"${FPCLI_PKG}\""
echo "include in your repo:  pushd /var/www/REPO-DIR"
echo "                       reprepro includedeb jessie \"${FPCLI_PKG}\" && popd"

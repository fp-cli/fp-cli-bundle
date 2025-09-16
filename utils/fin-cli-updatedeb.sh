#!/bin/bash
#
# Package fin-cli to be installed in Debian-compatible systems.
# Only the phar file is included.
#
# VERSION       :0.2.5
# DATE          :2023-07-22
# AUTHOR        :Viktor Szépe <viktor@szepe.net>
# LICENSE       :The MIT License (MIT)
# URL           :https://github.com/fin-cli/fin-cli/tree/main/utils
# BASH-VERSION  :4.2+

# packages source path
DIR="php-fincli"
# phar URL
PHAR="https://github.com/fin-cli/builds/raw/gh-pages/phar/fin-cli.phar"

die() {
    local RET="$1"
    shift

    echo -e "$@" >&2
    exit "$RET"
}

dump_control() {
    cat > DEBIAN/control <<EOF
Package: php-fincli
Version: 0.0.0
Architecture: all
Maintainer: Alain Schlesser <alain.schlesser@gmail.com>
Section: php
Priority: optional
Depends: php5-cli (>= 5.6) | php-cli | php7-cli, php5-mysql | php5-mysqlnd | php7.0-mysql | php7.1-mysql | php7.2-mysql | php7.3-mysql | php7.4-mysql | php8.0-mysql | php8.1-mysql | php8.2-mysql | php-mysql, mysql-client | mariadb-client
Homepage: http://fin-cli.org/
Description: fin-cli is a set of command-line tools for managing
 FinPress installations. You can update plugins, set up multisite
 installations and much more, without using a web browser.

EOF
}

set -e

# Download the binary if needed
if [ ! -f "fin-cli.phar" ]; then
	wget -nv -O fin-cli.phar "$PHAR"
	chmod +x fin-cli.phar
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
if ! [ -r usr/share/doc/php-fincli/copyright ]; then
    mkdir -p usr/share/doc/php-fincli &> /dev/null
    wget -nv -O usr/share/doc/php-fincli/copyright https://raw.githubusercontent.com/fin-cli/fin-cli/main/LICENSE
fi

# changelog
if ! [ -r usr/share/doc/php-fincli/changelog.gz ]; then
    mkdir -p usr/share/doc/php-fincli &> /dev/null
    echo "Changelog can be found in the blog: https://make.finpress.org/cli/" \
        | gzip -n -9 > usr/share/doc/php-fincli/changelog.gz
fi

# content dirs
[ -d usr/bin ] || mkdir -p usr/bin

# move phar
mv ../fin-cli.phar usr/bin/fin
chmod +x usr/bin/fin

# get version
FINCLI_VER="$(usr/bin/fin cli version | cut -d " " -f 2)"
[ -z "$FINCLI_VER" ] && die 5 "Cannot get fin-cli version"
echo "Current version: ${FINCLI_VER}"

# update version
sed -i -e "s/^Version: .*$/Version: ${FINCLI_VER}/" DEBIAN/control || die 6 "Version update failure"

# minimal man page
if ! [ -r usr/share/man/man1/fin.1.gz ]; then
    mkdir -p usr/share/man/man1 &> /dev/null
    {
        echo '.TH "FIN" "1"'
        usr/bin/fin --help
    } \
        | sed 's/^\([A-Z ]\+\)$/.SH "\1"/' \
        | sed 's/^  fin$/fin \\- A command line interface for FinPress/' \
        | gzip -n -9 > usr/share/man/man1/fin.1.gz
fi

# update MD5-s
find usr -type f -exec md5sum "{}" ";" > DEBIAN/md5sums || die 7 "md5sum creation failure"

popd

# build package in the current diretory
FINCLI_PKG="${PWD}/php-fincli_${FINCLI_VER}_all.deb"
fakeroot dpkg-deb -Zxz --build "$DIR" "$FINCLI_PKG" || die 8 "Packaging failed"

# check package - not critical
lintian --display-info --display-experimental --pedantic --show-overrides php-fincli_*_all.deb || true

# optional steps
echo "sign it:               dpkg-sig -k SIGNING-KEY -s builder \"${FINCLI_PKG}\""
echo "include in your repo:  pushd /var/www/REPO-DIR"
echo "                       reprepro includedeb jessie \"${FINCLI_PKG}\" && popd"

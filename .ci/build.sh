#!/usr/bin/env bash
# SPDX-License-Identifier: LGPL-2.1-or-later

set -ex

shopt -s nullglob

info() { echo -e "\033[33;1m$1\033[0m"; }
fatal() { echo >&2 -e "\033[31;1m$1\033[0m"; exit 1; }
success() { echo >&2 -e "\033[32;1m$1\033[0m"; }

ARGS=(
    "-Db_lto=true -Ddns-over-tls=false"
)
PACKAGES=(
    cryptsetup-bin
    expect
    fdisk
    gettext
    iputils-ping
    isc-dhcp-client
    itstool
    kbd
    libblkid-dev
    libbpf-dev
    libcap-dev
    libcurl4-gnutls-dev
    libfdisk-dev
    libfido2-dev
    libgpg-error-dev
    liblz4-dev
    liblzma-dev
    libmicrohttpd-dev
    libmount-dev
    libp11-kit-dev
    libpwquality-dev
    libqrencode-dev
    libssl-dev
    libtss2-dev
    libxen-dev
    libxkbcommon-dev
    libxtables-dev
    libzstd-dev
    mold
    mount
    net-tools
    python3-evdev
    python3-jinja2
    python3-lxml
    python3-pefile
    python3-pip
    python3-pyelftools
    python3-pyparsing
    python3-setuptools
    quota
    strace
    unifont
    util-linux
    zstd
)
COMPILER="gcc"
COMPILER_VERSION="14"
LINKER="bfd"
CRYPTOLIB="openssl"
RELEASE="noble"

if [[ "$COMPILER" == gcc ]]; then
    CC="gcc-$COMPILER_VERSION"
    CXX="g++-$COMPILER_VERSION"
    AR="gcc-ar-$COMPILER_VERSION"
    CFLAGS=""
    CXXFLAGS=""

    if ! apt-get -y install --dry-run "gcc-$COMPILER_VERSION" >/dev/null; then
        # Latest gcc stack deb packages provided by
        # https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test
        sudo add-apt-repository -y --no-update ppa:ubuntu-toolchain-r/test
    fi

    PACKAGES+=("gcc-$COMPILER_VERSION" "gcc-$COMPILER_VERSION-multilib")
else
    fatal "Unknown compiler: $COMPILER"
fi

# This is added by default, and it is often broken, but we don't need anything from it
sudo rm -f /etc/apt/sources.list.d/microsoft-prod.{list,sources} || true
# add-apt-repository --enable-source does not work on deb822 style sources.
for f in /etc/apt/sources.list.d/*.sources; do
    sudo sed -i "s/Types: deb/Types: deb deb-src/g" "$f"
done
sudo apt-get -y update
sudo apt-get -y build-dep systemd
sudo apt-get -y install "${PACKAGES[@]}"
# Install more or less recent meson and ninja with pip, since the distro versions don't
# always support all the features we need (like --optimization=). Since the build-dep
# command above installs the distro versions, let's install the pip ones just
# locally and add the local bin directory to the $PATH.
pip3 install --user -r .github/workflows/requirements.txt --require-hashes --break-system-packages
export PATH="$HOME/.local/bin:$PATH"

$CC --version
meson --version
ninja --version

for args in "${ARGS[@]}"; do
    SECONDS=0

    if [[ "$COMPILER" == clang && "$args" =~ Wmaybe-uninitialized ]]; then
        # -Wmaybe-uninitialized is not implemented in clang
        continue
    fi

    info "Checking build with $args"
    # shellcheck disable=SC2086
    if ! AR="$AR" \
         CC="$CC" CC_LD="$LINKER" CFLAGS="$CFLAGS" \
         CXX="$CXX" CXX_LD="$LINKER" CXXFLAGS="$CXXFLAGS" \
         meson setup \
               -Dtests=unsafe -Dslow-tests=true -Dfuzz-tests=true --werror \
               -Dnobody-group=nogroup -Dcryptolib="${CRYPTOLIB:?}" -Ddebug=false \
               $args build; then

        cat build/meson-logs/meson-log.txt
        fatal "meson failed with $args"
    fi

    if ! meson compile -C build -v; then
        fatal "'meson compile' failed with '$args'"
    fi

    for loader in build/src/boot/efi/*{.efi,.efi.stub}; do
        if [[ "$(sbverify --list "$loader" 2>&1)" != "No signature table present" ]]; then
            fatal "$loader: Gaps found in section table"
        fi
    done

    success "Build with '$args' passed in $SECONDS seconds"
done

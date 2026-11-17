# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Brave Origin privacy-focused web browser"
HOMEPAGE="https://brave.com/"
SRC_URI="https://github.com/brave/brave-browser/releases/download/v${PV}/brave-origin_${PV}_amd64.deb"

S="${WORKDIR}"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="bindist mirror strip"

RDEPEND="
    app-accessibility/at-spi2-core
    app-misc/ca-certificates
    dev-libs/expat
    dev-libs/glib:2
    dev-libs/nspr
    dev-libs/nss
    media-fonts/liberation-fonts
    media-libs/alsa-lib
    media-libs/mesa
    net-misc/curl
    net-print/cups
    sys-apps/dbus
    sys-libs/glibc
    x11-libs/cairo
    x11-libs/gtk+:3
    x11-libs/libX11
    x11-libs/libXcomposite
    x11-libs/libXdamage
    x11-libs/libXext
    x11-libs/libXfixes
    x11-libs/libXrandr
    x11-libs/libxcb
    x11-libs/libxkbcommon
    x11-libs/pango
    x11-misc/xdg-utils
"

QA_PREBUILT="opt/brave.com/brave-origin/*"

src_unpack() {
    unpack_deb "${A}"
}

src_install() {
    local target="/opt/brave.com/brave-origin"

    [[ -d "${S}${target}" ]] ||
        die "Missing Brave Origin payload"

    dodir /opt/brave.com

    cp -a "${S}${target}" \
        "${ED}/opt/brave.com/" ||
        die "Failed to install Brave payload"

    # Qt integration is not required for our GTK/X11 environment.
    rm -f "${ED}${target}/libqt5_shim.so" \
          "${ED}${target}/libqt6_shim.so" || die "Qt shim removal failed"

    fperms 4755 "${target}/chrome-sandbox"

    newbin "${FILESDIR}/brave-origin-launcher" \
        brave-origin-stable

    dosym /usr/bin/brave-origin-stable \
        /usr/bin/brave-origin

    if [[ -d "${S}/usr/share/applications" ]]; then
        insinto /usr/share/applications
        doins "${S}"/usr/share/applications/*.desktop
    fi

    if [[ -d "${S}/usr/share/icons" ]]; then
        dodir /usr/share/icons
        cp -a "${S}/usr/share/icons/." \
            "${ED}/usr/share/icons/" ||
            die "Failed to install icons"
    fi
}

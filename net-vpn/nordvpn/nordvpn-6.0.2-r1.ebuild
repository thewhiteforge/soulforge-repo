EAPI=8

inherit unpacker

DESCRIPTION="NordVPN command-line client and daemon (upstream binary package)"
HOMEPAGE="https://nordvpn.com/ https://github.com/NordSecurity/nordvpn-linux"
SRC_URI="https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${PV}_amd64.deb"
S="${WORKDIR}"

# Some upstream libraries (including libquench/libmoose) are not distributed as source.
LICENSE="GPL-3 all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="mirror strip"

RDEPEND="
    acct-group/nordvpn
    app-misc/ca-certificates
    dev-db/sqlite:3
    dev-libs/libnl:3
    dev-libs/libxslt
    net-dns/libidn2
    sys-apps/iproute2
    sys-libs/libcap-ng
    sys-libs/zlib
    sys-process/procps
"

QA_PREBUILT="*"
QA_MULTILIB_PATHS="usr/lib/nordvpn/.*"

src_unpack() {
    unpack_deb "${DISTDIR}/${A}"
}

src_install() {
    # The upstream daemon expects its private libraries and helper executables
    # under exactly /usr/lib/nordvpn, including on amd64 multilib systems.
    insinto /usr/lib/nordvpn
    doins "${S}"/usr/lib/nordvpn/*.so
    exeinto /usr/lib/nordvpn
    doexe "${S}"/usr/lib/nordvpn/{nordfileshare,norduserd,openvpn}

    # Bundled libraries depend on unversioned libsqlite3.so; use the ABI link.
    dosym "/usr/$(get_libdir)/libsqlite3.so.0" /usr/lib/nordvpn/libsqlite3.so

    # Gentoo's env.d integration supplies the linker library search path;
    # vendor Debian ldconfig/postinst scripts are NEVER executed.
    printf '%s\n' 'LDPATH="/usr/lib/nordvpn"' > "${T}/50nordvpn" || die
    doenvd "${T}/50nordvpn"

    dobin "${S}/usr/bin/nordvpn"
    dosbin "${S}/usr/sbin/nordvpnd"

    insinto /var/lib/nordvpn/data
    doins "${S}"/var/lib/nordvpn/data/*
    keepdir /var/log/nordvpn

    newinitd "${FILESDIR}/nordvpn.initd" nordvpn
    newconfd "${FILESDIR}/nordvpn.confd" nordvpn

    insinto /usr/share/bash-completion/completions
    doins "${S}/usr/share/bash-completion/completions/nordvpn"
    insinto /usr/share/licenses/nordvpn
    doins "${S}/usr/share/licenses/nordvpn/THIRD-PARTY-NOTICES.md"
    if [[ -f ${S}/usr/share/man/man1/nordvpn.1.gz ]]; then
        gzip -dc "${S}/usr/share/man/man1/nordvpn.1.gz" > "${T}/nordvpn.1" || die
        doman "${T}/nordvpn.1"
    fi
}

pkg_postinst() {
    elog "NordVPN is installed but its daemon has not been enabled or started."
    elog "After runtime validation and separate approval, use OpenRC to start it."
    elog "Group membership for the nordvpn socket needs a new login session."
    elog "Keep SSH/NAS recovery access before enabling VPN firewall features."
}

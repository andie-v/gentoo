# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools pam systemd

DESCRIPTION="Lightweight but featured SMTP daemon from OpenBSD"
HOMEPAGE="https://www.opensmtpd.org"
SRC_URI="https://www.opensmtpd.org/archives/${P/_}.tar.gz"

LICENSE="ISC BSD BSD-1 BSD-2 BSD-4"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"
IUSE="berkdb +mta pam split-usr"

# < openssl 3 for bug #881701
DEPEND="
	acct-user/smtpd
	acct-user/smtpq
	<dev-libs/openssl-3:=
	elibc_musl? ( sys-libs/fts-standalone )
	sys-libs/zlib
	pam? ( sys-libs/pam )
	berkdb? ( sys-libs/db:= )
	dev-libs/libevent:=
	app-misc/ca-certificates
	net-mail/mailbase
	net-libs/libasr
	virtual/libcrypt:=
	!mail-mta/courier
	!mail-mta/esmtp
	!mail-mta/exim
	!mail-mta/mini-qmail
	!mail-mta/msmtp[mta]
	!mail-mta/netqmail
	!mail-mta/nullmailer
	!mail-mta/postfix
	!mail-mta/qmail-ldap
	!mail-mta/sendmail
	!mail-mta/ssmtp[mta]
"
RDEPEND="${DEPEND}"
BDEPEND="app-alternatives/yacc"

S=${WORKDIR}/${P/_}

PATCHES=(
	"${FILESDIR}"/${P}-ar.patch #720782
	"${FILESDIR}"/${P}-implicit-function-declaration.patch #727260, 896050, 899876
	"${FILESDIR}"/${P}-strict-prototypes.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--sysconfdir=/etc/smtpd \
		--with-path-mbox=/var/spool/mail \
		--with-path-empty=/var/empty \
		--with-path-socket=/run \
		--with-path-CAfile=/etc/ssl/certs/ca-certificates.crt \
		--with-user-smtpd=smtpd \
		--with-user-queue=smtpq \
		--with-group-queue=smtpq \
		--with-libevent="$(get_libdir)" \
		--with-libssl="$(get_libdir)" \
		$(use_with pam auth-pam) \
		$(use_with berkdb table-db)
}

src_install() {
	default
	newinitd "${FILESDIR}"/smtpd.initd smtpd
	systemd_dounit "${FILESDIR}"/smtpd.{service,socket}
	use pam && newpamd "${FILESDIR}"/smtpd.pam smtpd
	dosym smtpctl /usr/sbin/makemap
	dosym smtpctl /usr/sbin/newaliases
	if use mta ; then
		dodir /usr/sbin
		dosym smtpctl /usr/sbin/sendmail
		# on USE="-split-usr" system sbin and bin are merged
		# so symlink made above will collide with one below
		use split-usr && dosym ../sbin/smtpctl /usr/bin/sendmail
		mkdir -p "${ED}"/usr/$(get_libdir) || die
		ln -s --relative "${ED}"/usr/sbin/smtpctl "${ED}"/usr/$(get_libdir)/sendmail || die
	fi
}

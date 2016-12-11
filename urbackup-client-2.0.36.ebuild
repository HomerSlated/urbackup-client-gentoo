# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

DESCRIPTION="Client for UrBackup server"
HOMEPAGE="https://www.urbackup.org"
SRC_URI="https://hndl.urbackup.org/Client/${PV}/${P}.tar.gz"
S=${WORKDIR}/${P}.0

SLOT="0"
LICENSE="AGPL-3"
KEYWORDS="~amd64 ~x86"
IUSE="gcc-fortify headless zlib"

RDEPEND="
	>=dev-libs/crypto++-5.1
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-gcc-fortify.patch"
)

src_configure() {
	econf \
	$(use_enable gcc-fortify fortify) \
	$(use_enable headless) \
	$(use_with zlib)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc docs/urbackupclientbackend.1
}

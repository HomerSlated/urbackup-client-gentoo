# copyright © 2016 slated.org
# Distributed under the terms of the AGPLv3+
# $Header: $

EAPI=6
inherit wxwidgets l10n

PLOCALES="cs da de es fa fr it nl pl pt_BR ru sk uk zh_CN zh_TW"
PLOCALE_BACKUP="en"

DESCRIPTION="Client for UrBackup server"
HOMEPAGE="https://www.urbackup.org"
SRC_URI="https://ssl.webpack.de/beta.urbackup.org/Client/${PV}%20beta/${P}.0.tar.gz"
S=${WORKDIR}/${P}.0

SLOT="0"
LICENSE="AGPL-3"
KEYWORDS="~amd64 ~x86"
IUSE="hardened X zlib linguas_cs linguas_da linguas_de linguas_es linguas_fa linguas_fr linguas_it linguas_nl linguas_pl linguas_pt_BR linguas_ru linguas_sk linguas_uk linguas_zh_CN linguas_zh_TW"

RDEPEND="
	dev-db/sqlite
	X? ( x11-libs/wxGTK:2.9 )
	>=dev-libs/crypto++-5.1
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-gcc-fortify.patch"
	"${FILESDIR}/${P}-autoupdate.patch"
	"${FILESDIR}/${P}-manpage.patch"
	"${FILESDIR}/${P}-conf.patch"
	"${FILESDIR}/${P}-locale.patch"
)

src_configure() {
	econf \
	$(use_enable hardened fortify) \
	$(use_enable !X headless) \
	$(use_with zlib) \
	--disable-clientupdate
}

src_install() {
	dodir "${EPREFIX}"/usr/share/man/man1
	install_locale_docs() {
    local locale_doc="client/data/lang/$1/urbackup.mo"
		insinto "${EPREFIX}"/usr/share/locale/$1/LC_MESSAGES
		[[ ! -e ${locale_doc} ]] || doins ${locale_doc}
		}
	emake DESTDIR="${D}" install
	if use X
		then l10n_for_each_locale_do install_locale_docs
	fi
	insinto "${EPREFIX}"/etc/logrotate.d
	newins "${FILESDIR}"/logrotate_urbackupclient urbackupclient
	newconfd defaults_client urbackupclient
	doinitd "${FILESDIR}"/urbackupclient
}

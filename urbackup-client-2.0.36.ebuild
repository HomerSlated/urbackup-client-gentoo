# copyright © 2016 slated.org
# Distributed under the terms of the AGPLv3+
# $Header: $

EAPI=6
inherit wxwidgets l10n systemd

PLOCALES="cs da de es fa fr it nl pl pt_BR ru sk uk zh_CN zh_TW"
PLOCALE_BACKUP="en"

DESCRIPTION="Client for UrBackup server"
HOMEPAGE="https://www.urbackup.org"
SRC_URI="https://hndl.urbackup.org/Client/${PV}/${P}.tar.gz"
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
	"${FILESDIR}/${P}-etc-perms.patch"
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
	systemd_dounit "${FILESDIR}"/urbackup-client.service
	dodir "${EPREFIX}"/etc/urbackup
	insinto "${EPREFIX}"/etc/urbackup
	doins "${FILESDIR}"/snapshot.cfg
	insinto "${EPREFIX}"/usr/share/urbackup/scripts
	insopts -m0700
	doins "${FILESDIR}"/btrfs_create_filesystem_snapshot
	doins "${FILESDIR}"/btrfs_remove_filesystem_snapshot
	doins "${FILESDIR}"/dattobd_create_filesystem_snapshot
	doins "${FILESDIR}"/dattobd_remove_filesystem_snapshot
	doins "${FILESDIR}"/lvm_create_filesystem_snapshot
	doins "${FILESDIR}"/lvm_remove_filesystem_snapshot
}

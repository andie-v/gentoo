# Copyright 2021-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..11} )
inherit distutils-r1

DESCRIPTION="Command line util to draw images on terminals by using child windows"
HOMEPAGE="https://github.com/ueber-devel/ueberzug/"
SRC_URI="https://github.com/ueber-devel/ueberzug/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXres"
RDEPEND="
	${COMMON_DEPEND}
	dev-python/attrs[${PYTHON_USEDEP}]
	dev-python/docopt[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]"
DEPEND="
	${COMMON_DEPEND}
	x11-base/xorg-proto"

python_install() {
	distutils-r1_python_install

	# https://github.com/ueber-devel/ueberzug/issues/9
	rm -r -- "${D}$(python_get_sitedir)"/ueberzug/X || die
}

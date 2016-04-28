#!/bin/bash

set -e

# Release-dance code goes here.

# Constants
PRODUCT="Juris-M Word for Mac Integration"
IS_BETA="false"
FORK="jurism-word-for-mac-integration"
BRANCH="master"
CLIENT="jurism-word-for-mac-integration"
VERSION_ROOT="3.5.14m"
COMPILED_PLUGIN_URL="https://download.zotero.org/integration/Zotero-MacWord-Plugin-3.5.14.xpi"
SIGNED_STUB="juris_m_word_for_mac_integration-"

function xx-make-build-directory () {
    if [ -d "build" ]; then
        rm -fR build
    fi
    mkdir build
}

function xx-retrieve-compiled-plugin () {
    trap booboo ERR
    wget -O compiled-plugin.xpi "${COMPILED_PLUGIN_URL}" >> "${LOG_FILE}" 2<&1
    trap - ERR
    unzip compiled-plugin.xpi >> "${LOG_FILE}" 2<&1
    rm -f compiled-plugin.xpi
}

function xx-grab-install-rdf () {
    cp ../install.rdf .
}

function xx-fix-product-ids () {
    # LO
    sed -si "s/zoteroOpenOfficeIntegration@zotero.org/jurismOpenOfficeIntegration@juris-m.github.io/g" install.rdf
    sed -si "s/zoteroOpenOfficeIntegration@zotero.org/jurismOpenOfficeIntegration@juris-m.github.io/g" resource/installer.jsm
    # Mac
    sed -si "s/zoteroMacWordIntegration@zotero.org/jurismMacWordIntegration@juris-m.github.io/g" install.rdf
    sed -si "s/zoteroMacWordIntegration@zotero.org/jurismMacWordIntegration@juris-m.github.io/g" resource/installer.jsm
    # Win
    sed -si "s/zoteroWinWordIntegration@zotero.org/jurismWindWordIntegration@juris-m.github.io/g" install.rdf
    sed -si "s/zoteroWinWordIntegration@zotero.org/jurismWinWordIntegration@juris-m.github.io/g" resource/installer.jsm
}

function xx-fix-product-name () {
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" install.rdf
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" components/zoteroMacWordIntegration.js
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" components/zoteroMacWordIntegration2016Pipe.js
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" resource/installer.jsm
}

function xx-fix-contributor () {
    sed -si "/<\/em:developer>/a\        <em:contributor>Frank Bennett</em:contributor>" install.rdf
}

function xx-install-icon () {
    cp ../additives/mlz_z_32px.png install/zotero.png
    cp ../additives/mlz_z_32px.png chrome/zotero.png
}

function xx-add-install-check-module () {
    cp ../additives/install_check.jsm resource
}

function xx-fix-uuids () {
    sed -si "s/aa56c6c0-95f0-48c2-b223-b11b96b9c9e5/4D06FB64-2DDD-11E5-9A06-31DA1D5D46B0/g" chrome.manifest
    sed -si "s/aa56c6c0-95f0-48c2-b223-b11b96b9c9e5/4D06FB64-2DDD-11E5-9A06-31DA1D5D46B0/g" components/zoteroMacWordIntegration.js
    sed -si "s/ea584d70-2797-4cd1-8015-1a5f5fb85af7/5684D472-2DDD-11E5-B567-32DA1D5D46B0/g" chrome.manifest
    sed -si "s/ea584d70-2797-4cd1-8015-1a5f5fb85af7/5684D472-2DDD-11E5-B567-32DA1D5D46B0/g" components/zoteroMacWordIntegration.js
    sed -si "s/9c6e787b-27d7-4567-98d4-b57d0afa3d8c/6051A408-2DDD-11E5-9064-8ADA1D5D46B0/g" chrome.manifest
    sed -si "s/9c6e787b-27d7-4567-98d4-b57d0afa3d8c/6051A408-2DDD-11E5-9064-8ADA1D5D46B0/g" components/zoteroMacWordIntegration.js
    sed -si "s/b063dd87-5615-45c5-ac3d-4b0583034616/68DE1872-2DDD-11E5-B1F2-8EDA1D5D46B0/g" chrome.manifest
    sed -si "s/b063dd87-5615-45c5-ac3d-4b0583034616/68DE1872-2DDD-11E5-B1F2-8EDA1D5D46B0/g" components/zoteroMacWordIntegration.js
    sed -si "s/26522064-b955-4bb0-9ccb-37a5c8c96fa0/716558F2-2DDD-11E5-8D23-8FDA1D5D46B0/g" chrome.manifest
    sed -si "s/26522064-b955-4bb0-9ccb-37a5c8c96fa0/716558F2-2DDD-11E5-8D23-8FDA1D5D46B0/g" components/zoteroMacWordIntegration2016Pipe.js
}

function xx-fix-install () {
    # Name everywhere (twice per customer)
    sed -si "s/\(\"[^\"]*\)Zotero\( \|\"\)/\\1Juris-M\\2/g" resource/installer.jsm
    sed -si "s/\(\"[^\"]*\)Zotero\( \|\"\)/\\1Juris-M\\2/g" resource/installer.jsm
    # ID everywhere
    sed -si "s/zotero@chnm.gmu.edu/juris-m@juris-m.github.io/g" resource/installer.jsm
    sed -si "s/zotero@chnm.gmu.edu/juris-m@juris-m.github.io/g" resource/installer_common.jsm
    # URLs
    sed -si "s/\(url: *\"\)\([^\"]*\)/\\1juris-m.github.org\/downloads/g" resource/installer.jsm
    sed -si "s/zoteroMacWordIntegration@zotero.org/jurismMacWordIntegration@juris-m.github.io/g" resource/installer.jsm
}

function xx-insert-copyright-blocks () {
    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" resource/installer.jsm
    sed -si "/END OF INSERT/,/END LICENSE/d" resource/installer.jsm
    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" resource/installer_common.jsm
    sed -si "/END OF INSERT/,/END LICENSE/d" resource/installer_common.jsm
    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" components/zoteroMacWordIntegration.js
    sed -si "/END OF INSERT/,/END LICENSE/d" components/zoteroMacWordIntegration.js
}

function xx-apply-patches () {
    patch -p1 < ../additives/word-install-check.patch >> "${LOG_FILE}" 2<&1
    patch -p1 < ../additives/version-comparison.patch >> "${LOG_FILE}" 2<&1
}


function xx-make-the-bundle () {
    zip -r "${XPI_FILE}" * >> "${LOG_FILE}"
}

function build-the-plugin () {
        xx-make-build-directory

        cd build
        xx-retrieve-compiled-plugin
        xx-grab-install-rdf
        set-install-version
        xx-install-icon
        xx-fix-product-ids
        xx-fix-product-name
        xx-fix-contributor
        xx-install-icon
        xx-add-install-check-module
	    xx-fix-uuids
        xx-fix-install
        xx-apply-patches
        xx-insert-copyright-blocks
        xx-make-the-bundle
        cd ..
    }
    
. jm-sh/frontend.sh

/* main.qml -- Main GUI file
 * Manages the different pages of the project and the back key on android
 *
 * Copyright (C) 2017 Paul Goetzinger <paul70079@gmail.com>
 *
 * This file is part of WTFIsMyMoney.
 *
 * SPDX-License-Identifier: GPL-3.0
 * License-Filename: LICENSE/GPL-3.0.txt
 *
 * WTFIsMyMoney is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * WTFIsMyMoney is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with WTFIsMyMoney.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtQml 2.2

import "Database.js" as Database

ApplicationWindow {
    visible: true
    width: 480
    height: 720
    title: view_stack.currentItem.title === "" ? Qt.application.name : Qt.application.name + " - " + view_stack.currentItem.title

    id: window

    StackView {
        id: view_stack
        anchors.fill: parent
        initialItem: page_main

        onCurrentItemChanged: {
            if (depth === 1) {
                currentItem.updateEntries()
                currentItem.visible = true
            }
        }

    }

    Page_main{
        id: page_main
        db: Database
    }

    Page_new{
        id: page_new
        visible: false
        db: Database
    }

    Page_settings{
        id: page_settings
        visible: false
        db: Database
    }

    Page_chart{
        id: page_chart
        visible: false
        db: Database
    }

    Component.onCompleted: {
        Qt.application.displayName = "WTFIsMyMoney"
        if (Database.init(LocalStorage, Qt.application.version)) {
            page_main.changelog.open()
        }

        page_main.updateEntries();
    }

    onClosing: {
        if (Qt.platform.os === "android") {
            if (view_stack.depth <= 1) {
                close.accepted = true
            } else {
                view_stack.currentItem.cancel()
                close.accepted = false
            }
        }
    }
}

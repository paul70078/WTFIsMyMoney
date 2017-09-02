import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.2

import "database.js" as Db

Page {
    title: view_new_swipe.currentItem ? view_new_swipe.currentItem.title : ""
    id: page
    objectName: "create_new"

    property var categories: []
    property var main_category: ""
    property var sub_category: ""
    property bool newEntry: true
    property int nr;

    function reset() {
        view_new_swipe.setCurrentIndex(0)
        main_category = ""
        sub_category = ""
        categories = []
        view_new_swipe.removeItem(2)
        view_new_swipe.removeItem(1)
        var tmp = Db.getCategories();
        for (var i in tmp) {
            categories.push({
                name: tmp[i],
                sub: Db.getSubcategories(tmp[i])
            });
        }
        page_main.categories = categories
        page_content.datum = new Date;
        page_content.money = 0.0
        newEntry = true;
    }

    function load(item) {
        if (!item) {
            return
        }

        view_new_swipe.setCurrentIndex(0)
        main_category = item.category
        sub_category = item.subcategory
        categories = []
        var tmp = Db.getCategories();
        for (var i in tmp) {
            categories.push({
                name: tmp[i],
                sub: Db.getSubcategories(tmp[i])
            });
        }
        page_main.categories = categories
        main_category = item.category
        sub_category = item.subcategory
        for (var i in categories) {
            if (categories[i].name === main_category) {
                page_sub.model = categories[i].sub
            }
        }
        page_sub.setText(sub_category)
        page_content.datum = item.datestamp;
        page_content.money = item.money
        nr = item.nr
        newEntry = false
    }

    function cancel() {
        dialog.open()
    }

    Rectangle {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 56

        Text {
            text: page.title
            anchors.left: parent.left
            anchors.leftMargin: 72
            anchors.baseline: parent.bottom
            anchors.baselineOffset: -20
            font.pixelSize: 20
            color: "white"
        }

        color: Material.primary
    }


    SwipeView {
        id: view_new_swipe
        anchors.top: bar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: pageIndicator_new.top
        anchors.bottomMargin: 10
        currentIndex: 1

        function next() {
            if (currentIndex == 0) {
                if (view_new_swipe.count == 1) {
                    view_new_swipe.addItem(page_sub)
                }

                for (var i in categories) {
                    if (categories[i].name === main_category) {
                        page_sub.model = categories[i].sub
                    }
                }

                if (view_new_swipe.count == 3) {
                    sub_category = page_sub.getText()
                }

            } else if (currentIndex == 1) {
                if (view_new_swipe.count == 2) {
                    view_new_swipe.addItem(page_content)
                }
            }

            view_new_swipe.incrementCurrentIndex()
        }

        Page_new_main {
            id: page_main
            onChosen: {
                main_category = text
                view_new_swipe.next()
            }
        }
        Page_new_sub {
            id: page_sub
            onChosen: {
                sub_category = text
                view_new_swipe.next()
            }
        }
        Page_new_content {
            id: page_content
            onDone: {
                if (newEntry) {
                    Db.storeEntry(main_category, sub_category, datum, money)
                } else {
                    Db.updateEntry(nr, main_category, sub_category, datum, money)
                }

                view_stack.pop()
            }
        }

    }
    PageIndicator {
        id: pageIndicator_new
        count: view_new_swipe.count
        currentIndex: view_new_swipe.currentIndex
        anchors.bottom: button_new_cancel.visible ? button_new_cancel.top : parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Button {
        id: button_new_cancel
        visible: Qt.platform.os !== "android"
        text: "Abbrechen"
        anchors.bottom: parent.bottom
        width: parent.width
        onClicked: cancel()
    }


    Dialog {
        id: dialog
        title: "Abbrechen"
        standardButtons: Dialog.Ok | Dialog.Cancel

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        onAccepted: view_stack.pop()
    }

    Component.onCompleted: {
        Db.init(LocalStorage)
    }
}
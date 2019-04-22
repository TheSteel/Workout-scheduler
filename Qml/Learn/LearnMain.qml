import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls.Styles 1.4
import Qt.labs.folderlistmodel 2.11
import QtMultimedia 5.8
import QtQuick.Dialogs 1.3 as QD

import "../CustomControls"

Page {
    id: learnMain
    Component.onCompleted: {
        deleteButton.enabled = false
    }

    onFocusChanged: {
        if (focus)
            muscGroups.model = dataBase.getMuscleGroups()
    }
    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: parent.height / 30
        Text {
            text: qsTr("Выберите группу мышц")
            font.family: "Monotype Corsiva"
            font.bold: true
            font.pointSize: 12
            horizontalAlignment: Text.AlignHCenter
        }
        CustomComboBox {
            id: muscGroups
            width: parent.width / 1.5
            height: parent.height / 15
            onCurrentTextChanged: {
                exerDescript.clear()
                groupExers.model = dataBase.getExerList(currentText)
            }
        }
        Text {
            text: qsTr("Выберите упражнение")
            font.family: "Monotype Corsiva"
            font.bold: true
            font.pointSize: 12
            horizontalAlignment: Text.AlignHCenter
        }
        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width
            anchors.margins: 10
            spacing: 10
            CustomComboBox {
                id: groupExers
                width: muscGroups.width
                height: muscGroups.height
                onCurrentTextChanged: {
                    if (!currentText.length) {
                        //editButton.enabled = false
                        deleteButton.enabled = false
                        return
                    }
                    //editButton.enabled = true
                    deleteButton.enabled = true
                    var data = dataBase.getExercise(currentText,
                                                    muscGroups.currentText)
                    exerDescript.text = data[0]
                    //imgDir.folder = data[1]
                }
            }

            //            Button {
            //                id: editButton
            //                width: parent.width / 4
            //                flat: true
            //                text: "Edit"
            //                onClicked: {
            //                    newExerDialog.muscGroup = muscGroups.currentText
            //                    newExerDialog.exerName = groupExers.currentText
            //                    newExerDialog.isEditable = false
            //                    newExerDialog.exerDescr = exerDescript.text
            //                    newExerDialog.open()
            //                }
            //            }
            Button {
                id: deleteButton
                width: parent.width / 4
                height: muscGroups.height
                text: qsTr("Удалить")
                onClicked: {
                    dataBase.deleteExerFromList(groupExers.currentText,
                                                muscGroups.currentText)
                    exerDescript.clear()
                    groupExers.model = dataBase.getExerList(
                                muscGroups.currentText)
                }
            }
        }
        ScrollView {
            width: parent.width
            height: parent.height / 5
            TextArea {
                id: exerDescript
                textMargin: 5
                readOnly: true
                clip: true
                wrapMode: Text.WordWrap
                placeholderText: "Введите описание к упражнение (если необходимо)"

                background: Rectangle {
                    border.color: "blue"
                }
            }
        }
        //        PathView {
        //            id: imgView
        //            width: parent.width
        //            height: parent.height / 4
        //            model: imgDir
        //            pathItemCount: 3
        //            path: Path {
        //                startX: parent.width - imgView.width + 50
        //                startY: imgView.height / 2
        //                PathLine {
        //                    x: imgView.width - 50
        //                    y: imgView.height / 2
        //                }
        //            }
        //            delegate: Image {
        //                width: 100
        //                height: 100
        //                fillMode: Image.PreserveAspectFit
        //                source: model.filePath
        //                MouseArea {
        //                    anchors.fill: parent
        //                    onClicked: {
        //                        img.source = model.filePath
        //                    }
        //                }
        //            }
        //            Rectangle {
        //                anchors.fill: parent
        //                border.color: "blue"
        //                border.width: 3
        //            }
        //        }
    }

    //    FolderListModel {
    //        id: imgDir
    //        nameFilters: ["*.jpg", "*.png"]
    //    }

    //    Image {
    //        id: img
    //        anchors.centerIn: parent
    //        width: sourceSize.width > parent.width ? parent.width : sourceSize.width
    //        height: sourceSize.height > parent.height ? parent.height / 2 : sourceSize.height
    //        MouseArea {
    //            anchors.fill: parent
    //            onClicked: {
    //                img.source = ""
    //            }
    //        }
    //    }
    RoundButton {
        text: "+"
        radius: Math.round((parent.width / 6) / 2)
        width: Math.round(parent.width / 6)
        height: Math.round(parent.width / 6)
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        anchors.rightMargin: 100
        onClicked: {
            newExerDialog.setMuscGroupModel()
            newExerDialog.open()
        }
    }
    //--------------------------------
    //add exersice dialog
    //--------------------------------
    //    ListModel {
    //        id: imgDialogModel
    //    }
    Dialog {
        id: newExerDialog
        implicitHeight: parent.height
        implicitWidth: parent.width
        closePolicy: Popup.NoAutoClose
        property string muscGroup: ""
        property string exerName: ""
        property string exerDescr: ""
        property bool isEditable: true
        function setMuscGroupModel() {
            muscGroupList.model = dataBase.getMuscleGroups()
        }

        onVisibleChanged: {
            mainWindow.disableToolBar(visible)
        }

        Column {
            anchors.margins: 10
            anchors.fill: parent
            spacing: parent.height / 30
            Text {
                width: parent.width
                text: qsTr("Мышечная группа")
                horizontalAlignment: Text.AlignHCenter
            }
            ComboBox {
                id: muscGroupList
                width: parent.width
                height: parent.height / 15
                editable: newExerDialog.isEditable
                model: dataBase.getMuscleGroups()
                background: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 40
                    border.color: muscGroupList.pressed ? "#17a81a" : "#21be2b"
                    border.width: muscGroupList.visualFocus ? 2 : 1
                    radius: 2
                }
                popup: Popup {
                    y: muscGroupList.height - 1
                    width: muscGroupList.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: muscGroupList.popup.visible ? muscGroupList.delegateModel : null
                        currentIndex: muscGroupList.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator {
                        }
                    }

                    background: Rectangle {
                        border.color: "#21be2b"
                        radius: 2
                    }
                }
                onCurrentIndexChanged: {
                    if (currentIndex)
                        muscGroupList.editable = false
                    else {
                        muscGroupList.editable = true
                    }
                }
            }
            TextField {
                text: newExerDialog.exerName
                id: newExerName
                width: parent.width
                placeholderText: "Введите название упражнения"
            }
            ScrollView {
                width: parent.width
                height: parent.height / 3
                TextArea {
                    id: newExerDescript
                    textMargin: 5
                    clip: false
                    text: newExerDialog.exerDescr
                    wrapMode: TextEdit.WrapAnywhere
                    placeholderText: "Введите описание к упражнение (если необходимо)"
                    background: Rectangle {
                        border.color: "blue"
                    }
                }
            }
            //            Row {
            //                width: parent.width
            //                height: 20
            //                spacing: 50
            //                Button {
            //                    id: addImg
            //                    height: parent.height
            //                    text: qsTr("Add image")
            //                    onClicked: {
            //                        imgDialog.open()
            //                    }
            //                }
            //                Button {
            //                    id: deleteImg
            //                    height: parent.height
            //                    text: qsTr("Delete image")
            //                    onClicked: {
            //                        imgDialogModel.remove(imgDialogModel.data(
            //                                                  imgDialogModel.count))
            //                    }
            //                }
            //            }

            //            PathView {
            //                id: dialogImgView
            //                width: parent.width
            //                height: parent.height / 4
            //                pathItemCount: 3
            //                model: imgDialogModel
            //                path: Path {
            //                    startX: parent.width - imgView.width + 50
            //                    startY: imgView.height / 2
            //                    PathLine {
            //                        x: imgView.width - 50
            //                        y: imgView.height / 2
            //                    }
            //                }
            //                delegate: Image {
            //                    width: 100
            //                    height: 100
            //                    fillMode: Image.PreserveAspectFit
            //                    source: filePath
            //                }
            //                Rectangle {
            //                    anchors.fill: parent
            //                    border.color: "blue"
            //                    border.width: 3
            //                }
            //            }
        }
        standardButtons: DialogButtonBox.Apply | DialogButtonBox.Cancel
        onApplied: {
            if (!muscGroupList.editText.length || !newExerName.text.length) {
                warningMessage.open()
                return
            }
            //            var sss = ""
            //            for (var i = 0; i < imgDialogModel.count; ++i) {
            //                sss += imgDialogModel.get(i).filePath
            //            }
            dataBase.insertExerToList(newExerName.text, muscGroupList.editText,
                                      newExerDescript.text)
            groupExers.model = dataBase.getExerList(muscGroupList.editText)
            close()
        }

        onRejected: {
            muscGroupList.model = ""
            close()
        }

        //        QD.FileDialog {
        //            id: imgDialog
        //            nameFilters: ["(*.jpg *.png)"]
        //            selectMultiple: true
        //            onAccepted: {
        //                if (fileUrls.length) {
        //                    for (var i = 0; i < fileUrls.length; ++i) {
        //                        imgDialogModel.append({
        //                                                  "filePath": fileUrls[i]
        //                                              })
        //                    }
        //                }
        //                close()
        //            }
        //            onRejected: {
        //                close()
        //            }
        //        }
    }
    QD.MessageDialog {
        id: warningMessage
        title: qsTr("Введите или выберите группу мышц")
    }

    //    FolderListModel {
    //        id: videoDir
    //        folder: "file:/Projects/TestQML/test/video"
    //        nameFilters: ["*.wmv", "*.mp4"]
    //    }
    //    PathView {
    //        id: videoView
    //        anchors.top: imgView.bottom
    //        anchors.left: parent.left
    //        anchors.right: parent.right
    //        height: parent.height / 3
    //        anchors.margins: 10
    //        model: videoDir
    //        pathItemCount: 3
    //        path: Path {
    //            startX: learnMain.width - videoView.width + 20
    //            startY: videoView.height / 2
    //            PathLine {
    //                x: videoView.width - 20
    //                y: videoView.height / 2
    //            }
    //        }
    //        delegate: Video {
    //            id: video
    //            width: 100
    //            height: 100
    //            fillMode: VideoOutput.PreserveAspectFit
    //            source: model.filePath
    //            autoLoad: true
    //            Rectangle {
    //                anchors.fill: parent
    //                border.color: "blue"
    //            }
    //            MouseArea {
    //                anchors.fill: parent
    //                onClicked: {
    //                    player.source = model.filePath
    //                    player.play()
    //                }
    //            }
    //        }
    //    }
    //    Item {
    //        anchors.centerIn: parent
    //        width: 400
    //        height: 300
    //        MediaPlayer {
    //            id: player
    //        }
    //        VideoOutput {
    //            anchors.fill: parent
    //            source: player
    //        }
    //    }
}

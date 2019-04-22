import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls.Styles 1.4

import "../CustomControls"

Page {
    function updateProgrammInfo() {
        programm.model = dataBase.getProgrammList()
        trainDay.model = dataBase.getTrainDays(programm.model[0])
    }
    function updateLastTrainig() {
        lastTrain.text = dataBase.getLastTraining(
                    "programm_" + programm.currentText + "_" + trainDay.currentText)
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        Text {
            id: programm_lbl
            width: parent.width / 2
            height: parent.height / 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Выберите программу")
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        CustomComboBox {
            id: programm
            anchors.top: programm_lbl.bottom
            anchors.topMargin: 10
            width: parent.width / 2
            height: parent.height / 10
            anchors.horizontalCenter: parent.horizontalCenter
            model: dataBase.getProgrammList()
            onCurrentTextChanged: {
                trainDay.model = dataBase.getTrainDays(currentText)
            }
        }
        Text {
            id: trainDay_lbl
            anchors.top: programm.bottom
            anchors.topMargin: 30
            width: parent.width / 2
            height: parent.height / 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Выберите тренировочный день")
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        CustomComboBox {
            id: trainDay
            anchors.top: trainDay_lbl.bottom
            anchors.topMargin: 10
            width: parent.width / 2
            height: parent.height / 10
            anchors.horizontalCenter: parent.horizontalCenter
            onCurrentIndexChanged: {
                lastTrain.text = dataBase.getLastTraining(
                            "programm_" + programm.currentText + "_" + model[currentIndex])
            }
        }
        Text {
            id: lastTrain_lbl
            anchors.top: trainDay.bottom
            anchors.topMargin: 30
            width: parent.width / 2
            height: parent.height / 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Последняя тренировка")
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            id: lastTrain
            anchors.top: lastTrain_lbl.bottom
            anchors.topMargin: 10
            width: parent.width / 2
            height: parent.height / 10
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
    RoundButton {
        radius: 40
        width: parent.width / 2
        height: parent.height / 10
        anchors.margins: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: qsTr("Начать тренировку")
        onClicked: {
            trainingPage.tableName = "programm_" + programm.currentText + "_" + trainDay.currentText
            trainingPage.restDuration = dataBase.getTrainDayRest(
                        programm.currentText, trainDay.currentText)
            trainingPage.setModel()
            stackView.push(trainingPage)
        }
    }

    TrainingPage {
        id: trainingPage
        visible: false
    }
}

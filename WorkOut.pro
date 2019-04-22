QT += quick widgets quickcontrols2 sql
CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
    circletimer.cpp \
    databasehandler.cpp \
    listmodel.cpp \
    trainingmodel.cpp \
    trainlistmodel.cpp

RESOURCES += \
    rsc.qrc

QTPLUGIN += dsengine

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    circletimer.h \
    databasehandler.h \
    listmodel.h \
    trainingmodel.h \
    trainlistmodel.h

OTHER_FILES += \
    WorkOut.db3

win32 {
  PWD_WIN = $${PWD}
  DESTDIR_WIN = $${OUT_PWD}
  PWD_WIN ~= s,/,\\,g
  DESTDIR_WIN ~= s,/,\\,g
  copydata.commands = copy $${PWD_WIN}\WorkOut.db3 $${DESTDIR_WIN}\WorkOut.db3
  QMAKE_EXTRA_TARGETS += copydata
  POST_TARGETDEPS += copydata
}

android {
  data.files = $$PWD/WorkOut.db3
  data.path = /assets/
  INSTALLS += data
}

ANDROID_PACKAGE_SOURCE_DIR = \
   $$PWD/android

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat


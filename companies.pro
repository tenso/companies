QT += qml quick sql

CONFIG += c++11

SOURCES += src/main.cpp \
    src/SqlTableModel.cpp

RESOURCES += src/qml.qrc \
    fonts.qrc \
    images.qrc

DEFINES += QT_DEPRECATED_WARNINGS

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

OTHER_FILES += \
    src/qml/*.qml \
    README.md

HEADERS += \
    src/Log.hpp \
    src/SqlTableModel.hpp

win32 {
#I have bug where qml will not be repacked if sub modules are saved.
#use this workaround:
runtouch.commands = copy /b $$shell_path($${PWD}/src/qml/main.qml) +,,;
QMAKE_EXTRA_TARGETS = runtouch
PRE_TARGETDEPS = runtouch
}

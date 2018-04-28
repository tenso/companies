QT += qml quick

CONFIG += c++11

SOURCES += src/main.cpp

RESOURCES += src/qml.qrc

DEFINES += QT_DEPRECATED_WARNINGS

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

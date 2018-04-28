QT += qml quick sql

CONFIG += c++11

SOURCES += src/main.cpp \
    src/DBModel.cpp

RESOURCES += src/qml.qrc

DEFINES += QT_DEPRECATED_WARNINGS

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    src/DBModel.hpp \
    src/Log.hpp

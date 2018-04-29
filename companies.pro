QT += qml quick sql

CONFIG += c++11

SOURCES += src/main.cpp \
    src/SqlTableModel.cpp

RESOURCES += src/qml.qrc

DEFINES += QT_DEPRECATED_WARNINGS

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RCC_DIR += src/qml/

OTHER_FILES += \
    src/qml/*.qml

HEADERS += \
    src/Log.hpp \
    src/SqlTableModel.hpp

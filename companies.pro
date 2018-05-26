QT += widgets qml quick sql

CONFIG += c++11

SOURCES += src/main.cpp \
    src/DataManager.cpp \
    src/Analysis.cpp \
    src/AnalysisDebug.cpp \
    src/Log.cpp \
    src/SqlModel.cpp \
    src/IdValueModel.cpp \
    src/RamTableModel.cpp \
    src/GlobalData.cpp


RESOURCES += src/qml.qrc \
    assets/fonts.qrc \
    assets/images.qrc \
    assets/db.qrc

DEFINES += QT_DEPRECATED_WARNINGS

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

OTHER_FILES += \
    src/qml/*.qml \
    README.md \
    data/*.sql

HEADERS += \
    src/Log.hpp \
    src/DataManager.hpp \
    src/Analysis.hpp \
    src/AnalysisDebug.hpp \
    src/SqlModel.hpp \
    src/IdValueModel.hpp \
    src/RamTableModel.hpp \
    src/GlobalData.hpp

win32 {
#I have bug where qml will not be repacked if sub modules are saved.
#use this workaround:
runtouch.commands = copy /b $$shell_path($${PWD}/src/qml/*.qml) +,,;
QMAKE_EXTRA_TARGETS = runtouch
PRE_TARGETDEPS = runtouch
}

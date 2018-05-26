#ifndef GLOBALDATA_HPP
#define GLOBALDATA_HPP

#include <QString>

class DataManager;
class SqlModel;

class GlobalData {
public:
    static void init(DataManager* dataManager);
    static SqlModel* getModel(const QString& name);
private:
    static DataManager* _data;
};

#endif // GLOBALDATA_HPP

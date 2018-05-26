#ifndef GLOBALDATA_HPP
#define GLOBALDATA_HPP

#include <QString>

class DataManager;
class RamTableModel;

class GlobalData {
public:
    static void init(DataManager* dataManager);
    static RamTableModel* getModel(const QString& name);
private:
    static DataManager* _data;
};

#endif // GLOBALDATA_HPP

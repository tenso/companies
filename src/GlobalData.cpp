#include "GlobalData.hpp"

#include "DataManager.hpp"
#include "RamTableModel.hpp"
#include "Log.hpp"

DataManager* GlobalData::_data {nullptr};

void GlobalData::init(DataManager *dataManager)
{
    _data = dataManager;
}

RamTableModel *GlobalData::getModel(const QString &name)
{
    if (!_data) {
        logError() << "null datamodel";
        return nullptr;
    }
    return _data->getModel(name);
}

#include "IdValueModel.hpp"
#include "Log.hpp"

IdValueModel::IdValueModel(QObject *parent)
    : RamTableModel(parent)
{
}

bool IdValueModel::init(const QString &table)
{
    setTable(table);
    addRole("id", true);
    addRole("name", false); //FIXME: change to "value"
    return true;
}

void IdValueModel::addPair(int id, const QVariant &value)
{
    newRow("id", id);
    set("name", value);
}

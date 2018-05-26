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
    addRole("value", false);
    return true;
}

void IdValueModel::addPair(int id, const QVariant &value)
{
    newRow("id", id);
    set("value", value);
}

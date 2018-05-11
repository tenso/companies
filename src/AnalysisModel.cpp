#include "AnalysisModel.hpp"

AnalysisModel::AnalysisModel(QObject *parent)
    : QAbstractItemModel(parent)
{
}

QVariant AnalysisModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    // FIXME: Implement me!
}

QModelIndex AnalysisModel::index(int row, int column, const QModelIndex &parent) const
{
    // FIXME: Implement me!
    //return createIndex(row, column);
}

QModelIndex AnalysisModel::parent(const QModelIndex &index) const
{
    return QModelIndex();
}

int AnalysisModel::rowCount(const QModelIndex &parent) const
{
    if (!parent.isValid())
        return 0;

    // FIXME: Implement me!
}

int AnalysisModel::columnCount(const QModelIndex &parent) const
{
    if (!parent.isValid())
        return 0;

    // FIXME: Implement me!
}

QVariant AnalysisModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    // FIXME: Implement me!
    return QVariant();
}

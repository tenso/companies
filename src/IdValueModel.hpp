#ifndef IDVALUEMODEL_HPP
#define IDVALUEMODEL_HPP

#include "RamTableModel.hpp"
#include <QList>

class IdValueModel : public RamTableModel
{
    Q_OBJECT

public:
    explicit IdValueModel(QObject *parent = nullptr);
    virtual bool init(const QString& table);

    void addPair(int id, const QVariant& value);
};

#endif // IDVALUEMODEL_HPP

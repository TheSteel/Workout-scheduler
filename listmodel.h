#pragma once

#include <QAbstractListModel>
#include <QStringList>
#include "databasehandler.h"

struct ListItem {
  explicit ListItem(const QString& itemName, int min, int sec);
  explicit ListItem(const QString& itemName);
  explicit ListItem(const QString& itemName, const QString& repeats,
                    const QString& workWeight);

  const QString& getItemName() const;
  int getMin() const;
  int getSec() const;
  const QString& getRepeats() const;
  const QString& getWorkWeight() const;

  void setName(const QString& itemName);
  void setMin(int min);
  void setSec(int sec);

 private:
  QString m_name;
  int m_min;
  int m_sec;
  QString m_repeats;
  QString m_workWeight;
};

class ListModel : public QAbstractListModel {
  Q_OBJECT
 public:
  explicit ListModel(QObject* parent = Q_NULLPTR);
  virtual ~ListModel() {}
  enum ModelRoles {
    nameRole = Qt::UserRole + 1,
    minRole,
    secRole,
    repeatRole,
    weightRole
  };
  int rowCount(const QModelIndex& parent = QModelIndex()) const;
  QVariant data(const QModelIndex& index,
                int role = ModelRoles::nameRole) const;
  QHash<int, QByteArray> roleNames() const;
  // add programm
  Q_INVOKABLE bool addItem(const QString& itemName);
  // add training day
  Q_INVOKABLE bool addItem(const QString& itemName, int restMin, int restSec,
                           const QString& tableName);

  // add exercise list
  Q_INVOKABLE void addItem(const QString& itemName, const QString& exerList,
                           const QString& weight, const QString& tableName);

  //  Q_INVOKABLE void removeItem(const int row);
  Q_INVOKABLE void removeItem(const int row,
                              const QString& tableName = "programm");

  Q_INVOKABLE void setupModel(
      const QString& tableName = "", uint rev = 0
      /*rev 0 = programm, 1 = training day, 2 = exercise */);
  void initDB(DataBaseHandler* base);
  Q_INVOKABLE void clearModel();

 private:
  QList<ListItem> m_items;
  QString m_tableName;
  DataBaseHandler* p_db;
};

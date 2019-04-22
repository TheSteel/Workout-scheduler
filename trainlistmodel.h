#pragma once

#include <QObject>
#include <QList>

#include "databasehandler.h"

class TrainItem {
 public:
  explicit TrainItem(QString name);
  explicit TrainItem();
  ~TrainItem();
  QString getName();
  float getWeight();
  int getRepeat();

  void setName(QString name);
  void setWeight(float weight);
  void setRepeat(int repeat);
  Q_INVOKABLE void setIsOpen(bool);

  Q_INVOKABLE void appendChild(TrainItem *);
  Q_INVOKABLE QList<TrainItem *> getChildItems();
  Q_INVOKABLE void removeChild();

  Q_INVOKABLE bool isOpen();
  Q_INVOKABLE bool hasChilds();

 private:
  QString m_name;
  float m_weight;
  int m_repeat;
  QList<TrainItem *> m_childList;
  bool m_isOpen;
};

class TrainListModel : public QObject {
  Q_OBJECT
 public:
  explicit TrainListModel(QObject *parent = nullptr);
  ~TrainListModel();

  Q_INVOKABLE bool setupModel(const QString &tableName);
  Q_INVOKABLE QList<TrainItem *> getItemList();
  void initDB(DataBaseHandler *);

 signals:

 public slots:

 private:
  QList<TrainItem *> m_rootItems;
  DataBaseHandler *p_db;
};

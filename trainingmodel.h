#pragma once

#include <QAbstractListModel>
#include <QList>
#include "databasehandler.h"

#pragma pack(push, 1)
struct TrainingData {
  explicit TrainingData();
  ~TrainingData();

  void setName(const QString &name);
  void setParams(float weight, int repeat);
  void setIsOpen();
  void setParentPos(int pos);
  void setWeight(float val);
  void setRepeat(int val);
  void setWeightIncr(float val);
  void setRepeatIncr(int val);
  void setIsRoot(bool val);

  const QString &getName() const;
  const QList<TrainingData *> &getChilds() const;
  float getWeight() const;
  int getRepeat() const;
  int getParentPos() const;
  bool isOpened() const;
  bool isRoot() const;
  float getWeightIncr() const;
  int getRepeatIncr() const;

  void addChild(TrainingData *);
  void removeChild();
  bool hasChilds();

 private:
  QString m_name;
  float m_weight;
  int m_repeat;
  QList<TrainingData *> m_childList;
  bool m_isOpen;
  int m_parentPos;
  float m_weightIncr;
  int m_repeatIncr;
  bool m_isRoot;
};
#pragma pack(pop)

class TrainingModel : public QAbstractListModel {
  Q_OBJECT
 public:
  explicit TrainingModel(QObject *parent = nullptr);
  virtual ~TrainingModel();
  enum TrainingModelRoles {
    EXERCISE = Qt::UserRole + 1,
    REPEAT,
    WEIGHT,
    HASCHILDS,
    ISOPEN,
    ISROOT
  };

  Q_INVOKABLE void initDB(DataBaseHandler *db);
  Q_INVOKABLE bool setupModel(const QString &tableName);

  Q_INVOKABLE void openItem(int index);
  Q_INVOKABLE void closeItem(int index);

  Q_INVOKABLE float getWeightIncr(int index);
  Q_INVOKABLE int getRepeatIncr(int index);

  Q_INVOKABLE void setWeightIncr(float val, int index);
  Q_INVOKABLE void setRepeatIncr(int val, int row);

  Q_INVOKABLE void setWeight(float val, int row);
  Q_INVOKABLE void setRepeat(int val, int row);

  Q_INVOKABLE void addRepeat(int row);
  Q_INVOKABLE void removeRepeat(int row);
  Q_INVOKABLE void saveToBase(const QString &tableName);
  void clearModel();

  // QAbstractItemModel interface
  int rowCount(const QModelIndex &parent = QModelIndex()) const;
  QVariant data(const QModelIndex &index, int role) const;
  QHash<int, QByteArray> roleNames() const;

 private:
  QList<TrainingData *> m_items;
  DataBaseHandler *p_db;
};

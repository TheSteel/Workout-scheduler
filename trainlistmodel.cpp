#include <QStringList>

#include "trainlistmodel.h"

#include <QDebug>

TrainItem::TrainItem(QString name)
    : m_name(name), m_weight(0.), m_repeat(0), m_isOpen(false) {}

TrainItem::TrainItem() : m_weight(0.), m_repeat(0), m_isOpen(false) {}

TrainItem::~TrainItem() { qDeleteAll(m_childList); }

QString TrainItem::getName() { return m_name; }

float TrainItem::getWeight() { return m_weight; }

int TrainItem::getRepeat() { return m_repeat; }

void TrainItem::setName(QString name) { m_name = name; }

void TrainItem::setWeight(float weight) { m_weight = weight; }

void TrainItem::setRepeat(int repeat) { m_repeat = repeat; }

void TrainItem::setIsOpen(bool state) { m_isOpen = state; }

void TrainItem::appendChild(TrainItem *item) { m_childList.append(item); }

QList<TrainItem *> TrainItem::getChildItems() { return m_childList; }

void TrainItem::removeChild() { m_childList.removeLast(); }

bool TrainItem::isOpen() { return m_isOpen; }

bool TrainItem::hasChilds() { return m_childList.isEmpty(); }

///////////////////////////////////////
//////////////////////////////////////
//////////////////////////////////////

TrainListModel::TrainListModel(QObject *parent) : QObject(parent) {}

TrainListModel::~TrainListModel() { qDeleteAll(m_rootItems); }

bool TrainListModel::setupModel(const QString &tableName) {
  int count = p_db->getExerciseCount(tableName);
  QStringList data = p_db->getExerciseData(tableName, count);
  if (data.isEmpty()) return false;
  for (int i = 0, j = 0; i < count; ++i, j += 3) {
    qDebug() << j;
    TrainItem *p = new TrainItem(data[i]);
    m_rootItems.append(p);
    QStringList weight = data[j + 1].split(",", QString::SkipEmptyParts);
    QStringList repeats = data[j + 2].split(",", QString::SkipEmptyParts);
    qDebug() << "Name: " << data[j];
    for (int k = 0; k < weight.count(); ++k) {
      TrainItem *i = new TrainItem();
      i->setWeight(weight[k].toInt());
      i->setRepeat(repeats[k].toInt());
      p->appendChild(i);
      qDebug() << "W: " << weight[k].toInt();
      qDebug() << "R: " << repeats[k].toInt();
    }
  }
  return true;
}

QList<TrainItem *> TrainListModel::getItemList() { return m_rootItems; }

void TrainListModel::initDB(DataBaseHandler *db) { p_db = db; }

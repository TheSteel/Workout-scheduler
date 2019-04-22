#include <cmath>

#include "trainingmodel.h"

#include <QDebug>

template <typename T>
static bool floatPointCompare(T val1, T val2) {
  return (std::fabs(val1 - val2) <=
          std::numeric_limits<T>::epsilon() *
              std::fmax(std::fabs(val1), std::fabs(val2)));
}

TrainingData::TrainingData()
    : m_weight(0.),
      m_repeat(0),
      m_isOpen(false),
      m_parentPos(-1),
      m_weightIncr(1.0),
      m_repeatIncr(1),
      m_isRoot(false) {}

TrainingData::~TrainingData() { qDeleteAll(m_childList); }

void TrainingData::setName(const QString &name) { m_name = name; }

void TrainingData::setParams(float weight, int repeat) {
  m_weight = weight;
  m_repeat = repeat;
}

void TrainingData::setIsOpen() { m_isOpen = !m_isOpen; }

void TrainingData::setParentPos(int pos) { m_parentPos = pos; }

void TrainingData::setWeight(float val) {
  if (floatPointCompare(m_weight, val)) return;
  m_weight = val;
}

void TrainingData::setRepeat(int val) { m_repeat = val; }

void TrainingData::setWeightIncr(float val) {
  if (floatPointCompare(m_weightIncr, val)) return;
  m_weightIncr = val;
}

void TrainingData::setRepeatIncr(int val) { m_repeatIncr = val; }

void TrainingData::setIsRoot(bool val) { m_isRoot = val; }

const QString &TrainingData::getName() const { return m_name; }

const QList<TrainingData *> &TrainingData::getChilds() const {
  return m_childList;
}

float TrainingData::getWeight() const { return m_weight; }

int TrainingData::getRepeat() const { return m_repeat; }

int TrainingData::getParentPos() const { return m_parentPos; }

bool TrainingData::isOpened() const { return m_isOpen; }

bool TrainingData::isRoot() const { return m_isRoot; }

float TrainingData::getWeightIncr() const { return m_weightIncr; }

int TrainingData::getRepeatIncr() const { return m_repeatIncr; }

void TrainingData::addChild(TrainingData *data) { m_childList.append(data); }

void TrainingData::removeChild() { m_childList.removeLast(); }

bool TrainingData::hasChilds() { return !m_childList.isEmpty(); }

////////////////////////////////////////
/// \brief TrainingModel::TrainingModel
/// \param parent
///

TrainingModel::TrainingModel(QObject *parent) : QAbstractListModel(parent) {}

TrainingModel::~TrainingModel() { qDeleteAll(m_items); }

void TrainingModel::initDB(DataBaseHandler *db) { p_db = db; }

bool TrainingModel::setupModel(const QString &tableName) {
  if (!m_items.isEmpty()) {
    clearModel();
  }
  beginResetModel();
  int count = p_db->getExerciseCount(tableName);
  QStringList data = p_db->getExerciseData(tableName, count);
  if (data.isEmpty()) return false;
  for (int i = 0, j = 0; i < count; ++i, j += 3) {
    TrainingData *item = new TrainingData();
    item->setName(data[j]);
    item->setIsRoot(true);
    m_items.append(item);
    QStringList weight = data[j + 2].split(",", QString::SkipEmptyParts);
    QStringList repeats = data[j + 1].split(",", QString::SkipEmptyParts);
    for (int k = 0; k < weight.count(); ++k) {
      TrainingData *childItem = new TrainingData();
      childItem->setName(QString::number(k + 1));
      childItem->setParams(weight[k].toFloat(), repeats[k].toInt());
      item->addChild(childItem);
    }
  }
  endResetModel();
  return true;
}

void TrainingModel::openItem(int row) {
  int size = m_items.count();
  int childs = m_items.at(row)->getChilds().count();
  if (row < 0 || row > size - 1 || !childs) return;
  if (m_items.at(row)->isOpened()) return;
  QModelIndex modelIndex = index(row);
  m_items.at(row)->setIsOpen();
  emit dataChanged(modelIndex, modelIndex);
  int i = row + 1;
  beginInsertRows(QModelIndex(), i, i + childs - 1);
  foreach (TrainingData *item, m_items.at(row)->getChilds()) {
    item->setParentPos(row);
    m_items.insert(i++, item);
  }
  endInsertRows();
}

void TrainingModel::closeItem(int row) {
  int size = m_items.count();
  int childs = m_items.at(row)->getChilds().count();
  if (row < 0 || row > size - 1 || !childs) return;
  QModelIndex modelIndex = index(row);
  m_items.at(row)->setIsOpen();
  emit dataChanged(modelIndex, modelIndex);
  int i = row + 1;
  int bot = i + childs - 1;
  beginRemoveRows(QModelIndex(), i, bot);
  while (bot > row) {
    m_items.removeAt(bot--);
  }
  endRemoveRows();
}

float TrainingModel::getWeightIncr(int index) {
  if (index < 0) return 1.;
  int parentPos = m_items.at(index)->getParentPos();
  return m_items.at(parentPos)->getWeightIncr();
}

int TrainingModel::getRepeatIncr(int index) {
  if (index < 0) return 1;
  int parentPos = m_items.at(index)->getParentPos();
  return m_items.at(parentPos)->getRepeatIncr();
}

void TrainingModel::setWeightIncr(float val, int index) {
  m_items.at(index)->setWeightIncr(val);
}

void TrainingModel::setRepeatIncr(int val, int row) {
  m_items.at(row)->setRepeatIncr(val);
}

void TrainingModel::setWeight(float val, int row) {
  m_items.at(row)->setWeight(val);
}

void TrainingModel::setRepeat(int val, int row) {
  m_items.at(row)->setRepeat(val);
}

void TrainingModel::addRepeat(int row) {
  TrainingData *rootItem = m_items.at(row);
  TrainingData *newItem;
  if (rootItem->getChilds().isEmpty())
    newItem = new TrainingData();
  else
    newItem = new TrainingData(*rootItem->getChilds().last());
  newItem->setParentPos(row);
  newItem->setName(QString::number(rootItem->getChilds().count() + 1));
  rootItem->addChild(newItem);
  emit dataChanged(index(row), index(row));
  if (rootItem->isOpened()) {
    int newRow = row + rootItem->getChilds().count();
    beginInsertRows(QModelIndex(), newRow, newRow);
    m_items.insert(newRow, newItem);
    endInsertRows();
  }
}

void TrainingModel::removeRepeat(int row) {
  TrainingData *rootItem = m_items.at(row);
  if (rootItem->getChilds().isEmpty()) return;
  rootItem->removeChild();
  emit dataChanged(index(row), index(row));
  if (rootItem->isOpened()) {
    int bot = row + rootItem->getChilds().count() + 1;
    beginRemoveRows(QModelIndex(), bot, bot);
    m_items.removeAt(bot);
    endRemoveRows();
  }
}

void TrainingModel::saveToBase(const QString &tableName) {
  Q_FOREACH (TrainingData *item, m_items) {
    if (!item->hasChilds()) continue;
    QString weight;
    QString repeat;
    Q_FOREACH (TrainingData *childItem, item->getChilds()) {
      weight.append(QString::number(childItem->getWeight()) + ",");
      repeat.append(QString::number(childItem->getRepeat()) + ",");
    }
    weight.chop(1);
    repeat.chop(1);
    p_db->insertExercise(item->getName(), repeat, weight, tableName, false);
  }
}

void TrainingModel::clearModel() {
  beginRemoveRows(QModelIndex(), 0, m_items.count() - 1);
  while (!m_items.isEmpty()) {
    m_items.removeLast();
  }
  endRemoveRows();
}

int TrainingModel::rowCount(const QModelIndex &parent) const {
  Q_UNUSED(parent)
  return m_items.count();
}

QVariant TrainingModel::data(const QModelIndex &index, int role) const {
  if (!index.isValid()) return QVariant();

  int row = index.row();
  if (role == EXERCISE)
    return m_items.at(row)->getName();
  else if (role == REPEAT)
    return m_items.at(row)->getRepeat();
  else if (role == WEIGHT)
    return m_items.at(row)->getWeight();
  else if (role == HASCHILDS)
    return m_items.at(row)->hasChilds();
  else if (role == ISOPEN)
    return m_items.at(row)->isOpened();
  else if (role == ISROOT)
    return m_items.at(row)->isRoot();
  else
    return QVariant();
}

QHash<int, QByteArray> TrainingModel::roleNames() const {
  QHash<int, QByteArray> roles;
  roles[EXERCISE] = "exerRole";
  roles[REPEAT] = "repeatRole";
  roles[WEIGHT] = "weightRole";
  roles[HASCHILDS] = "haschildRole";
  roles[ISOPEN] = "isopenRole";
  roles[ISROOT] = "isRootRole";
  return roles;
}

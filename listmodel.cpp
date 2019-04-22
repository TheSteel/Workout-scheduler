#include <QDateTime>

#include "listmodel.h"

ListItem::ListItem(const QString &itemName, int min, int sec)
    : m_name(itemName), m_min(min), m_sec(sec) {}

ListItem::ListItem(const QString &itemName)
    : m_name(itemName), m_min(0), m_sec(0) {}

ListItem::ListItem(const QString &itemName, const QString &repeats,
                   const QString &workWeight)
    : m_name(itemName),
      m_min(0),
      m_sec(0),
      m_repeats(repeats),
      m_workWeight(workWeight) {}

const QString &ListItem::getItemName() const { return m_name; }

int ListItem::getMin() const { return m_min; }

int ListItem::getSec() const { return m_sec; }

const QString &ListItem::getRepeats() const { return m_repeats; }

const QString &ListItem::getWorkWeight() const { return m_workWeight; }

ListModel::ListModel(QObject *parent) : QAbstractListModel(parent) {}

int ListModel::rowCount(const QModelIndex &parent) const {
  Q_UNUSED(parent);
  return m_items.count();
}

QVariant ListModel::data(const QModelIndex &index, int role) const {
  int row = index.row();
  if (row < 0 || row > m_items.count()) return QVariant();
  if (role == nameRole)
    return m_items.at(row).getItemName();
  else if (role == minRole)
    return m_items.at(row).getMin();
  else if (role == secRole)
    return m_items.at(row).getSec();
  else if (role == repeatRole)
    return m_items.at(row).getRepeats();
  else if (role == weightRole)
    return m_items.at(row).getWorkWeight();
  else
    return QVariant();
}

QHash<int, QByteArray> ListModel::roleNames() const {
  QHash<int, QByteArray> roles;
  roles[nameRole] = "nameRole";
  roles[secRole] = "secRole";
  roles[minRole] = "minRole";
  roles[repeatRole] = "repeatRole";
  roles[weightRole] = "weightRole";
  return roles;
}

bool ListModel::addItem(const QString &itemName) {
  int row = m_items.count();
  if (p_db->insertProgramm(itemName)) {
    beginInsertRows(QModelIndex(), row, row);
    m_items.append(ListItem(itemName));
    endInsertRows();
    return true;
  }
  return false;
}

bool ListModel::addItem(const QString &itemName, int restMin, int restSec,
                        const QString &tableName) {
  int row = m_items.count();
  if (p_db->insertTrainDay(itemName, restMin, restSec, tableName)) {
    beginInsertRows(QModelIndex(), row, row);
    m_items.append(ListItem(itemName, restMin, restSec));
    endInsertRows();
    return true;
  }
  return false;
}

void ListModel::addItem(const QString &itemName, const QString &repeats,
                        const QString &weight, const QString &tableName) {
  int row = m_items.count();
  if (p_db->insertExercise(itemName, repeats, weight, tableName)) {
    beginInsertRows(QModelIndex(), row, row);
    m_items.append(ListItem(itemName, repeats, weight));
    endInsertRows();
  }
}

void ListModel::removeItem(const int row, const QString &tableName) {
  if (row < 0 || row > m_items.count())
    return;
  else {
    QString name = m_items.at(row).getItemName();
    if (p_db->deleteRecord(tableName, name) &&
        p_db->dropLinkedTables(tableName)) {
      beginRemoveRows(QModelIndex(), row, row);
      m_items.removeAt(row);
      endRemoveRows();
    }
  }
}

void ListModel::setupModel(const QString &tableName, uint rev) {
  if (!m_items.isEmpty()) clearModel();
  beginResetModel();
  switch (rev) {
    case 0: {
      QStringList data = p_db->getProgrammList();
      for (int i = 0; i < data.count(); ++i) {
        m_items.append(ListItem(data.at(i)));
      }
      break;
    }
    case 1: {
      QStringList data = p_db->getTrainDayData(tableName);
      int i = 0;
      while (i < data.size() - 1) {
        m_items.append(ListItem(data[i],
                                QTime::fromString(data[i + 1]).minute(),
                                QTime::fromString(data[i + 1]).second()));
        i += 2;
      }
      break;
    }
    case 2: {
      int count = p_db->getExerciseCount(tableName);
      QStringList data = p_db->getExerciseData(tableName, count);
      if (count <= 0) break;
      int i = 0;
      int j = 0;
      int size = data.size() / count;
      while (i < count) {
        m_items.append(ListItem(data[j], data[j + 1], data[j + 2]));
        ++i;
        j += size;
      }
      break;
    }
    default:
      break;
  }
  endResetModel();
}

void ListModel::initDB(DataBaseHandler *base) { p_db = base; }

void ListModel::clearModel() {
  beginRemoveRows(QModelIndex(), 0, m_items.count() - 1);
  while (!m_items.isEmpty()) {
    m_items.removeLast();
  }
  endRemoveRows();
}

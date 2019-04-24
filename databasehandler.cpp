#include <QTime>
#include <QSqlQueryModel>
#include <QDir>
#include <QGuiApplication>
#include <QStandardPaths>
#include <QSqlRecord>

#include "databasehandler.h"

DataBaseHandler::DataBaseHandler(QObject *parent) : QObject(parent) {}

DataBaseHandler::~DataBaseHandler() { closeBase(); }

void DataBaseHandler::connectToBase() { openBase(); }

bool DataBaseHandler::openBase() {
  QString filePath;
#ifdef ANDROID
  filePath = QStandardPaths::writableLocation(
      QStandardPaths::StandardLocation::AppDataLocation);
  filePath.append("/WorkOut.db3");
  if (!QFile(filePath).exists()) {
    QFile file("assets:/WorkOut.db3");
    file.copy(filePath);
    QFile::setPermissions(filePath, QFile::WriteOwner | QFile::ReadOwner);
  }
#else
  filePath = "WorkOut.db3";
#endif

  m_db = QSqlDatabase::addDatabase("QSQLITE");
  m_db.setDatabaseName(filePath);
  if (m_db.open()) {
    p_query = new QSqlQuery(m_db);
    createProgrammListTable();
    createExerciseTable();
    return true;
  } else {
    qDebug() << "cant open base";
    return false;
  }
}

void DataBaseHandler::closeBase() { m_db.close(); }

void DataBaseHandler::restoreBase() {
  QFile("WorkOut.db3").open(QFile::WriteOnly);
  openBase();

  QFile("WorkOut.db3").close();
}

bool DataBaseHandler::createProgrammListTable() {
  if (p_query->exec(
          "CREATE TABLE IF NOT EXISTS programm (id INTEGER PRIMARY KEY "
          "AUTOINCREMENT,"
          "name VARCHAR UNIQUE NOT NULL)"))
    return true;
  else {
    qDebug() << "error while create programmlist table: "
             << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::createExerciseTable() {
  if (p_query->exec("CREATE TABLE IF NOT EXISTS exerciseList (id INTEGER "
                    "PRIMARY KEY AUTOINCREMENT,"
                    "name STRING UNIQUE NOT NULL, muscleGroup STRING, descript "
                    "STRING, imgSource STRING, videoSource STRING)"))
    return true;
  else {
    qDebug() << "error while create exerList table: "
             << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::createProgrammDaysTable(const QString &tableName) {
  QString data = tableName;
  data.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  data.replace(" ", "$");
  if (p_query->exec(
          "CREATE TABLE IF NOT EXISTS " + data +
          " (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR UNIQUE "
          "NOT NULL, rest TIME, exerciseCount INTEGER DEFAULT 0)"))
    return true;
  else {
    qDebug() << "error while create programm days table: "
             << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::createTrainDayTable(const QString &tableName) {
  QString data = tableName;
  qDebug() << data;
  data.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  data.replace(" ", "$");
  qDebug() << "Train DAY: " << data;
  if (p_query->exec(
          "CREATE TABLE IF NOT EXISTS " + data +
          " (id INTEGER PRIMARY KEY AUTOINCREMENT, date DATETIME, name "
          "VARCHAR UNIQUE "
          "NOT NULL, repeat STRING, weight "
          "STRING)"))
    return true;
  else {
    qDebug() << "error while create train day table: "
             << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::insertProgramm(const QString &name) {
  QString data = name;
  data.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  p_query->prepare(
      "INSERT INTO programm (name)"
      "VALUES(:name)");
  p_query->bindValue(":name", data);
  if (p_query->exec())
    return true;
  else {
    qDebug() << "error while insert into programm: "
             << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::insertTrainDay(const QString &name, int restMin,
                                     int restSec, const QString &progName) {
  QString data = progName;
  data.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  data.replace(" ", "$");
  QString newName = name;
  newName.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  p_query->prepare("INSERT INTO " + data +
                   " (name, rest)"
                   "VALUES(:name, :rest)");
  p_query->bindValue(":name", newName);
  p_query->bindValue(":rest", QTime(0, restMin, restSec));
  if (p_query->exec())
    return true;
  else {
    qDebug() << "error while insert into trainingday: "
             << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::insertExercise(const QString &name,
                                     const QString &repeats,
                                     const QString &weight,
                                     const QString &dayName, bool update) {
  QString data = dayName;
  data.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  data.replace(" ", "$");
  if (isExerciseExists(data, name))
    return updateExersice(name, repeats, weight, data);

  p_query->prepare("INSERT INTO " + data +
                   " (name, date,repeat, weight) "
                   "VALUES(:name, :date,:repeat, :weight)");
  p_query->bindValue(":name", name);
  p_query->bindValue(":date", QDateTime::currentDateTime());
  p_query->bindValue(":repeat", repeats);
  p_query->bindValue(":weight", weight);
  if (p_query->exec()) {
    if (update) updateExerciseCount(data, true);
    return true;
  } else {
    qDebug() << "error while insert exercise: " << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::insertExerToList(const QString &name,
                                       const QString &group,
                                       const QString &descript,
                                       const QString &imgPath) {
  Q_UNUSED(imgPath)
  //  QDir dir;
  //  QStringList source = imgPath.split("file:///");
  //  source.removeFirst();
  //  QString path = QGuiApplication::applicationDirPath() + "/ExerList/";
  //  if (!dir.exists(path + group)) dir.mkdir(path + group);
  //  if (!dir.exists(path + group + "/" + name))
  //    dir.mkdir(path + group + "/" + name);
  //  for (int i = 0; i < source.count(); ++i) {
  //    QFileInfo info = source[i];
  //    QFile::copy(source[i], path + group + "/" + name + "/" +
  //    info.fileName());
  //    qDebug() << path + group + "/" + name + "/" + info.fileName();
  //  }
  p_query->prepare(
      "INSERT INTO exerciseList (name, muscleGroup, descript) "
      "VALUES (:name, :muscleGroup, :descript)");
  p_query->bindValue(":name", name);
  p_query->bindValue(":muscleGroup", group);
  p_query->bindValue(":descript", descript);
  //  p_query->bindValue(":imgSource",
  //                     "file:" + path.remove("D:") + group + "/" + name);
  if (p_query->exec())
    return true;
  else {
    qDebug() << "error while insert exercise to list: "
             << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::deleteRecord(const QString &tableName,
                                   const QString &record) {
  QString validName = tableName;
  validName.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  validName.replace(" ", "$");
  if (p_query->exec("DELETE FROM " + validName + " WHERE name = '" + record +
                    "'")) {
    QRegExp reg("(_[\\w$]+)(_[\\w$]+)");
    reg.indexIn(validName);
    if (reg.captureCount() > 1) updateExerciseCount(validName, false);
    QString validRecord = record;
    validRecord.remove(QRegExp("(^[ ]+)|([ ]+$)"));
    validRecord.replace(" ", "$");
    dropLinkedTables(validName + "_" + validRecord);
    return true;
  } else {
    qDebug() << "error while deleting from programm: "
             << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::deleteExerFromList(const QString &name,
                                         const QString &muscGroup) {
  if (p_query->exec("DELETE FROM exerciseList WHERE (name = '" + name +
                    "' AND muscleGroup = '" + muscGroup + "')"))
    return true;
  else
    return false;
}

bool DataBaseHandler::updateExerciseCount(const QString &tableName,
                                          bool isIncrement) {
  QRegExp getName("(_[\\w$]+)(_[\\w$]+)");
  getName.indexIn(tableName);
  if (isIncrement) {
    if (p_query->exec("UPDATE programm" + getName.cap(1) +
                      " SET exerciseCount = exerciseCount + 1 WHERE name = '" +
                      getName.cap(2).remove(0, 1).replace("$", " ") + "'"))
      return true;
    else {
      qDebug() << p_query->lastError().text();
      return false;
    }
  } else {
    if (p_query->exec("UPDATE programm" + getName.cap(1) +
                      " SET exerciseCount = exerciseCount - 1 WHERE name = '" +
                      getName.cap(2).remove(0, 1).replace("$", " ") + "'"))
      return true;
    else {
      qDebug() << p_query->lastError().text();
      return false;
    }
  }
}

bool DataBaseHandler::updateExersice(const QString &name,
                                     const QString &repeats,
                                     const QString &weight,
                                     const QString &dayName) {
  //  p_query->exec("SELECT id FROM " + dayName + " WHERE (name = '" + name +
  //                "' AND date = '" +
  //                QDate::currentDate().toString("yyyy-MM-dd") +
  //                "')");
  //  p_query->next();
  //  int id = p_query->value(0).toInt();
  //  qDebug() << id;
  //  if (p_query->exec("UPDATE " + dayName + " SET repeat = '" + repeats +
  //                    "' , weight = '" + weight + "' WHERE id = " +
  //                    QString::number(id)))
  if (p_query->exec("UPDATE " + dayName + " SET repeat = '" + repeats +
                    "', weight = '" + weight + "'WHERE id = (SELECT id FROM " +
                    dayName + " WHERE (name = '" + name + "' AND date = '" +
                    QDate::currentDate().toString("yyyy-MM-dd") + "'))"))
    return true;
  else {
    qDebug() << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::dropTable(const QString &tableName) {
  QString data = tableName;
  data.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  data.replace(" ", "$");
  if (p_query->exec("DROP TABLE " + data)) {
    return true;
  } else {
    qDebug() << "error while drop table: " + data
             << p_query->lastError().text();
    return false;
  }
}

bool DataBaseHandler::dropLinkedTables(const QString &tableName) {
  // QString data = tableName;
  // data.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  // data.replace(" ", "$");
  qDebug() << "In Drop Linked Tables " << tableName;
  if (!p_query->exec("SELECT name FROM sqlite_master WHERE name LIKE '" +
                     tableName + "_%'")) {
    qDebug() << "error while drop linked tables: " + tableName
             << p_query->lastError().text();
    return false;
  } else {
    QStringList names;
    while (p_query->next()) {
      names.append(p_query->value(0).toString());
    }
    int i = 0;
    qDebug() << names;
    while (i < names.size()) {
      p_query->exec("DROP TABLE " + names[i]);
      ++i;
    }
    p_query->exec("DROP TABLE " + tableName);
    return true;
  }
}

bool DataBaseHandler::isExerciseExists(const QString &tableName,
                                       const QString &exerName) {
  p_query->exec("SELECT repeat FROM " + tableName + " WHERE (date = '" +
                QDateTime::currentDateTime().toString() + "' AND name = '" +
                exerName + "')");
  p_query->next();
  if (p_query->value(0).isNull())
    return false;
  else
    return true;
}

QStringList DataBaseHandler::getProgrammList() const {
  QStringList names;
  p_query->exec("SELECT name FROM programm");
  while (p_query->next()) {
    names.append(p_query->value(0).toString());
  }
  return names;
}

QStringList DataBaseHandler::getTrainDayData(const QString &tableName) const {
  QString name = tableName;
  name.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  name.replace(" ", "$");
  qDebug() << name;
  if (p_query->exec("SELECT name, rest FROM " + name)) {
    QStringList data;
    while (p_query->next()) {
      data.append(p_query->value(0).toString());
      data.append(p_query->value(1).toString());
    }
    return data;
  } else {
    qDebug() << "error while selecting from training: "
             << p_query->lastError().text();

    return QStringList();
  }
}

QStringList DataBaseHandler::getExerciseData(const QString &tableName,
                                             int count) const {
  if (count <= 0) return QStringList();
  if (p_query->exec("SELECT name, repeat, weight FROM " + tableName +
                    " ORDER BY id DESC LIMIT " + QString::number(count))) {
    QStringList data;
    while (p_query->next()) {
      data.append(p_query->value(0).toString());
      data.append(p_query->value(1).toString());
      data.append(p_query->value(2).toString());
    }
    return data;
  } else {
    qDebug() << "error while selecting from exercise table: "
             << p_query->lastError().text();
    return QStringList();
  }
}

int DataBaseHandler::getExerciseCount(const QString &tableName) const {
  QString data = tableName;
  data.remove(QRegExp("(^[ ]+)|([ ]+$)"));
  data.replace(" ", "$");
  QRegExp getName("(_\\w+)(_\\w+)");
  getName.indexIn(data);
  if (p_query->exec("SELECT exerciseCount FROM programm" + getName.cap(1) +
                    " WHERE name = '" + getName.cap(2).remove(0, 1) + "'")) {
    if (p_query->next()) return p_query->value(0).toInt();
  }
  qDebug() << "Error while selecting count: " << p_query->lastError().text();
  return -1;
}

QStringList DataBaseHandler::getExerList(const QString &muscleGroupName) const {
  if (p_query->exec("SELECT name FROM exerciseList WHERE "
                    "muscleGroup = '" +
                    muscleGroupName + "'")) {
    QStringList data;
    while (p_query->next()) {
      data.append(p_query->value(0).toString());
    }
    return data;
  } else {
    qDebug() << "error while selecting from exerciseList: "
             << p_query->lastError().text();
    return QStringList();
  }
}

QStringList DataBaseHandler::getMuscleGroups() const {
  if (p_query->exec("SELECT DISTINCT muscleGroup from exerciseList")) {
    QStringList groups(" ");
    while (p_query->next()) {
      groups.append(p_query->value(0).toString());
    }
    return groups;
  } else
    return QStringList();
}

QStringList DataBaseHandler::getExercise(const QString &name,
                                         const QString &muscGroup) const {
  if (p_query->exec("SELECT descript, imgSource FROM exerciseList WHERE "
                    "(name = '" +
                    name + "' AND muscleGroup = '" + muscGroup + "')")) {
    QStringList data;
    while (p_query->next()) {
      data.append(p_query->value(0).toString());
      data.append(p_query->value(1).toString());
    }
    return data;
  } else {
    qDebug() << "error while selecting data from exerciseList: "
             << p_query->lastError().text();
    return QStringList();
  }
}

QStringList DataBaseHandler::getTrainDays(const QString &progName) const {
  if (progName.isEmpty()) return QStringList();
  p_query->exec("SELECT name FROM programm_" + progName);
  QStringList days;
  while (p_query->next()) {
    days.append(p_query->value(0).toString());
  }
  qDebug() << days;
  return days;
}

int DataBaseHandler::getTrainDayRest(const QString &progName,
                                     const QString &dayName) {
  if (p_query->exec("SELECT rest FROM programm_" + progName +
                    " WHERE name = '" + dayName + "'")) {
    QTime time;
    while (p_query->next()) {
      time = p_query->value(0).toTime();
    }
    return (time.minute() * 60 + time.second());
  } else {
    qDebug() << p_query->lastError().text();
    return 0;
  }
}

QString DataBaseHandler::getLastTraining(const QString &tableName) {
  if (p_query->exec("SELECT date FROM " + tableName +
                    " WHERE id = (SELECT MAX(id) FROM " + tableName + ")")) {
    while (p_query->next()) {
      qDebug() << p_query->value(0).toDateTime().toString();
      return p_query->value(0).toDateTime().toString();
    }
  }
  qDebug() << "Error while getting last training"
           << p_query->lastError().text();
  return QString();
}

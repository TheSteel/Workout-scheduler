#pragma once

#include <QObject>
#include <QFile>
#include <QSqlQuery>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDate>

#include <QDebug>

class DataBaseHandler : public QObject {
  Q_OBJECT
 public:
  explicit DataBaseHandler(QObject* parent = nullptr);
  ~DataBaseHandler();

  void connectToBase();
  bool createProgrammListTable();
  bool createExerciseTable();
  Q_INVOKABLE bool createProgrammDaysTable(const QString& tableName);
  Q_INVOKABLE bool createTrainDayTable(const QString& tableName);

  Q_INVOKABLE bool insertProgramm(const QString& name);
  Q_INVOKABLE bool insertTrainDay(const QString& name, int restMin, int restSec,
                                  const QString& progName);
  Q_INVOKABLE bool insertExercise(const QString& name, const QString& repeats,
                                  const QString& weight, const QString& dayName,
                                  bool update = true);
  Q_INVOKABLE bool insertExerToList(const QString& name, const QString& group,
                                    const QString& descript,
                                    const QString& imgPath = "");

  bool deleteRecord(const QString& tableName, const QString& record);
  Q_INVOKABLE bool deleteExerFromList(const QString& name,
                                      const QString& muscGroup);
  bool updateExerciseCount(const QString& tableName, bool isIncrement);
  bool updateExersice(const QString& name, const QString& repeats,
                      const QString& weight, const QString& dayName);

  Q_INVOKABLE QStringList getProgrammList() const;
  QStringList getTrainDayData(const QString& tableName) const;
  QStringList getExerciseData(const QString& tableName, int count) const;
  int getExerciseCount(const QString& tableName) const;
  Q_INVOKABLE QStringList getExerList(const QString& muscleGroupName) const;
  Q_INVOKABLE QStringList getMuscleGroups() const;
  Q_INVOKABLE QStringList getExercise(const QString& name,
                                      const QString& muscGroup) const;
  Q_INVOKABLE QStringList getTrainDays(const QString& progName) const;
  Q_INVOKABLE int getTrainDayRest(const QString& progName,
                                  const QString& dayName);
  Q_INVOKABLE QString getLastTraining(const QString& tableName);

  Q_INVOKABLE bool dropTable(const QString& tableName);
  Q_INVOKABLE bool dropLinkedTables(const QString& tableName);
  Q_INVOKABLE bool dropProgramm(const QString& progName);
  Q_INVOKABLE bool dropTraingDay(const QString& trainDay,
                                 const QString& progName);
  Q_INVOKABLE bool dropMuscleGroup(const QString& muscleGruop,
                                   const QString& progName);

  bool isExerciseExists(const QString& tableName, const QString& exerName);

 private:
  bool openBase();
  void closeBase();
  void restoreBase();

  QSqlDatabase m_db;
  QSqlQuery* p_query;
};

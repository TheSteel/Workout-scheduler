#include <QApplication>
#include <QCoreApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>
#include <QDir>

#include "databasehandler.h"
#include "listmodel.h"
#include "trainingmodel.h"
#include "circletimer.h"

#include <QDebug>

int main(int argc, char *argv[]) {
  QApplication app(argc, argv);
  app.setAttribute(Qt::AA_EnableHighDpiScaling);
  DataBaseHandler base;
  base.connectToBase();
  QQmlApplicationEngine engine;
  ListModel *model = new ListModel(&app);
  model->initDB(&base);
  model->setupModel();
  ListModel *dayModel = new ListModel(&app);
  dayModel->initDB(&base);
  ListModel *exerModel = new ListModel(&app);
  exerModel->initDB(&base);
  TrainingModel *trainModel = new TrainingModel(&app);
  trainModel->initDB(&base);
  QQmlContext *qmlContext = engine.rootContext();
  qmlContext->setContextProperty("listModel", model);
  qmlContext->setContextProperty("dayModel", dayModel);
  qmlContext->setContextProperty("exerModel", exerModel);
  qmlContext->setContextProperty("dataBase", &base);
  qmlContext->setContextProperty("trainingModel", trainModel);
  qmlRegisterType<CircleTimer>("CircleTimer", 1, 0, "CircleTimer");
  engine.load("qrc:/Qml/MainPage.qml");
  if (engine.rootObjects().isEmpty()) return -1;
  return app.exec();
}

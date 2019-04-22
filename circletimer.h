#pragma once

#include <QQuickPaintedItem>
#include <QPainter>
#include <QColor>
#include <QTimer>
#include <QTime>

class CircleTimer : public QQuickPaintedItem {
  Q_OBJECT
  Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE
                 setBackgroundColor NOTIFY backgroundColorChanged)
  Q_PROPERTY(QColor borderActiveColor READ borderActiveColor WRITE
                 setBorderActiveColor NOTIFY borderActiveColorChanged)
  Q_PROPERTY(QColor borderNonActiveColor READ borderNonActiveColor WRITE
                 setBorderNonActiveColor NOTIFY borderNonActiveChanged)
  Q_PROPERTY(QTime circleTime READ circleTime WRITE setCircleTime NOTIFY
                 circleTimeChanged)
  Q_PROPERTY(int angle READ angle WRITE setAngle NOTIFY angleChanged)

 public:
  explicit CircleTimer(QQuickItem *parent = nullptr);
  void paint(QPainter *painter) override;
  QColor backgroundColor() const;
  QColor borderActiveColor() const;
  QColor borderNonActiveColor() const;
  QTime circleTime() const;
  Q_INVOKABLE void start();
  Q_INVOKABLE void reset();
  Q_INVOKABLE void stop();
  int angle() const;
  QTime duartion() const;

 signals:
  void backgroundColorChanged(QColor backgroundColor);
  void borderActiveColorChanged(QColor borderActiveColor);
  void borderNonActiveChanged(QColor borderNonActiveColor);
  void circleTimeChanged(QTime circleTime);
  void angleChanged(int angle);
  void cleared();

  void durationChanged(QTime duration);

 public slots:
  void setBackgroundColor(QColor backgroundColor);
  void setBorderActiveColor(QColor borderActiveColor);
  void setBorderNonActiveColor(QColor borderNonActiveColor);
  void setAngle(int angle);
  Q_INVOKABLE void setDuration(int duration);

 private:
  void setCircleTime(QTime circleTime);
  QColor m_backgroundColor;
  QColor m_borderActiveColor;
  QColor m_borderNonActiveColor;
  QTime m_circleTime;
  QTime m_duration;
  int m_angle;
  QTimer *m_timer;
  int m_delta;
};

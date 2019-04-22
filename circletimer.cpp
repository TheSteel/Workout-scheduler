#include "circletimer.h"

CircleTimer::CircleTimer(QQuickItem *parent)
    : QQuickPaintedItem(parent),
      m_backgroundColor(Qt::white),
      m_borderActiveColor(Qt::blue),
      m_borderNonActiveColor(Qt::gray),
      m_circleTime(QTime(0, 0)),
      m_duration(QTime(0, 0)),
      m_angle(0),
      m_delta(0)

{
  m_timer = new QTimer(this);
  connect(m_timer, &QTimer::timeout, [=]() {
    setAngle(angle() - m_delta);
    setCircleTime(circleTime().addSecs(-1));
    update();
  });
}

void CircleTimer::paint(QPainter *painter) {
  QBrush brush(m_backgroundColor);
  QBrush brushActive(m_borderActiveColor);
  QBrush brushNonActive(m_borderNonActiveColor);

  painter->setPen(Qt::NoPen);
  painter->setRenderHints(QPainter::Antialiasing, true);
  painter->setBrush(brushNonActive);
  painter->drawEllipse(boundingRect().adjusted(1, 1, -1, -1));
  painter->setBrush(brushActive);
  painter->drawPie(boundingRect().adjusted(1, 1, -1, -1), 90 * 16,
                   m_angle * 16);
  painter->setBrush(brush);
  painter->drawEllipse(boundingRect().adjusted(10, 10, -10, -10));
}

void CircleTimer::setBackgroundColor(QColor backgroundColor) {
  if (m_backgroundColor == backgroundColor) return;

  m_backgroundColor = backgroundColor;
  emit backgroundColorChanged(m_backgroundColor);
}

void CircleTimer::setBorderActiveColor(QColor borderActiveColor) {
  if (m_borderActiveColor == borderActiveColor) return;

  m_borderActiveColor = borderActiveColor;
  emit borderActiveColorChanged(m_borderActiveColor);
}

void CircleTimer::setBorderNonActiveColor(QColor borderNonActiveColor) {
  if (m_borderNonActiveColor == borderNonActiveColor) return;

  m_borderNonActiveColor = borderNonActiveColor;
  emit borderNonActiveChanged(m_borderNonActiveColor);
}

void CircleTimer::setAngle(int angle) {
  m_angle = angle;
  emit angleChanged(m_angle);
  if (m_angle <= -360) {
    m_angle = 0;
    stop();
  }
}

void CircleTimer::setDuration(int duration) {
  m_duration = QTime(0, 0).addSecs(duration);
  setCircleTime(m_duration);
  m_delta = 360 / duration;
  emit durationChanged(m_duration);
}

void CircleTimer::setCircleTime(QTime circleTime) {
  if (m_circleTime == circleTime) return;
  m_circleTime = circleTime;
  emit circleTimeChanged(m_circleTime);
}

QColor CircleTimer::backgroundColor() const { return m_backgroundColor; }

QColor CircleTimer::borderActiveColor() const { return m_borderActiveColor; }

QColor CircleTimer::borderNonActiveColor() const {
  return m_borderNonActiveColor;
}

QTime CircleTimer::circleTime() const { return m_circleTime; }

void CircleTimer::start() { m_timer->start(1000); }

void CircleTimer::reset() {
  setCircleTime(m_duration);
  setAngle(0.);
  update();
  emit cleared();
}

void CircleTimer::stop() { m_timer->stop(); }

int CircleTimer::angle() const { return m_angle; }

QTime CircleTimer::duartion() const { return m_duration; }

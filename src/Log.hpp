#ifndef LOG_HPP
#define LOG_HPP

#include <QDebug>

enum LogColor {Reset, Black, White, Green, Red, Blue, Yellow, Cyan, Magenta};
const char *logColor(LogColor color);

#define logStatus() (qDebug() << "STATUS:")
#define logError() (qDebug() << "ERROR:" << __FILE__ << __LINE__ << __PRETTY_FUNCTION__)

#endif // LOG_HPP

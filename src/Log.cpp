#include "Log.hpp"

const char*  logColor(LogColor color)
{
    static const char* colors[] = { //'bright;fg;bgm'
        "\u001b[0m", "\u001b[1;30m", "\u001b[1;37m", "\u001b[1;32m", "\u001b[1;31m", "\u001b[1;34m",
        "\u001b[1;33m", "\u001b[1;36m", "\u001b[1;35m"
    };

    return colors[color];
}

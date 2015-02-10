/*
@Author:  Grant Douglas <@Hexploitable>
@Title:   MEMSCAN
@Desc:    A tool for memory analysis of iOS and OSX applications
@Vers:    1.0.1

@colour_defs.h: Definitions for TTY colours for stdout.
*/


#define red   "\033[1;31m"        /* 0 -> normal ;  31 -> red */
#define redU   "\033[4;31m"
#define cyan  "\033[0;36m"        /* 1 -> bold ;  36 -> cyan */
#define cyanU "\033[4;36m"
#define green "\033[0;32m"        /* 4 -> underline ;  32 -> green */
#define yellow "\033[0;33m"
#define yellowU "\033[4;33m"
#define blue  "\033[0;34m"        /* 9 -> strike ;  34 -> blue */
#define blueU "\033[4;34m"
#define black  "\033[0;30m"
#define brown  "\033[0;33m"
#define magenta  "\033[0;35m"
#define gray  "\033[0;37m"
#define uline   "\033[4;0m"
#define none   "\033[0m"        /* to flush the previous property */

/*
  @Author:  Grant Douglas <@Hexploitable>
  @Title:   MEMSCAN
  @Desc:    A tool for memory analysis of iOS and OSX applications
  @Vers:    1.0.1
*/

#include <stdio.h>

#include "colour_defs.h"

const char *version = "1.0.1";

//Just prints a gimmicky header + name + vers.
#define BANNER \
    printf(red); \
    printf(" __   __ "); \
    printf(" _______ "); \
    printf(" __   __ "); \
    printf(" _______ "); \
    printf(" _______ "); \
    printf(" _______ "); \
    printf(" __    _ \n"); \
    \
    printf("|  |_|  |"); \
    printf("|       |"); \
    printf("|  |_|  |"); \
    printf("|       |"); \
    printf("|       |"); \
    printf("|   _   |"); \
    printf("|  |  | |\n"); \
    \
    printf("|       |"); \
    printf("|    ___|"); \
    printf("|       |"); \
    printf("|  _____|"); \
    printf("|       |"); \
    printf("|  |_|  |"); \
    printf("|   |_| |\n"); \
    \
    printf("|       |"); \
    printf("|   |___ "); \
    printf("|       |"); \
    printf("| |_____ "); \
    printf("|       |"); \
    printf("|       |"); \
    printf("|       |\n"); \
    printf(cyan); \
    \
    printf("|       |"); \
    printf("|    ___|"); \
    printf("|       |"); \
    printf("|_____  |"); \
    printf("|      _|"); \
    printf("|       |"); \
    printf("|  _    |\n"); \
    \
    printf("| ||_|| |"); \
    printf("|   |___ "); \
    printf("| ||_|| |"); \
    printf(" _____| |"); \
    printf("|     |_ "); \
    printf("|   _   |"); \
    printf("| | |   |\n"); \
    \
    printf("|_|   |_|"); \
    printf("|_______|"); \
    printf("|_|   |_|"); \
    printf("|_______|"); \
    printf("|_______|"); \
    printf("|__| |__|"); \
    printf("|_|  |__|\n"); \
    printf("\n%sAuthor: %sGrant Douglas (@Hexploitable)%s", none, cyan, none); \
    printf("\nVersion: %s%s%s\n\n", cyan, version, none);

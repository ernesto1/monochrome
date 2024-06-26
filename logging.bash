#!/bin/bash
# set of methods for printing data in a nice format

NOCOLOR='\033[0m'
BLUE='\033[0;34m'
GREEN='\033[32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'

# prints the message using logback compatible formatting
# arguments:
#    message  string to print
function log {
  printf "$(date +'%T.%3N') ${BLUE}INFO  ${ORANGE}$(basename $0)${NOCOLOR} - $1\n"
}

# prints an error message to standard error using logback compatible formatting
# arguments:
#    message  string to print
function logError {
  printf "$(date +'%T.%3N') ${RED}ERROR ${ORANGE}$(basename $0)${NOCOLOR} - $1\n" >&2
}

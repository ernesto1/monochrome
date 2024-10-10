#!/bin/bash
# script to retrieve relevant system performance details not available in the conky api
# data is placed in files for conky to read

. ~/conky/monochrome/logging.bash

function renameTempFile {
  for f in "$@"
  do [[ -f ${f}.$$ ]] && mv ${f}.$$ ${f}
  done
}

OUTDIR=/tmp/conky
TMPFILE=${OUTDIR}/system.$$
SWAPREADFILE=${OUTDIR}/system.swap.read
SWAPWRITEFILE=${OUTDIR}/system.swap.write
CPUUSFILE=${OUTDIR}/system.cpu.us
CPUSYFILE=${OUTDIR}/system.cpu.sy
CPUIDFILE=${OUTDIR}/system.cpu.id
CPUWAFILE=${OUTDIR}/system.cpu.wa
trap 'log "received shutdown signal, deleting output files"; rm ${OUTDIR}/system.*; exit 0' EXIT

log 'compiling system performance metrics'
echo 'n/a' > ${SWAPREADFILE}
echo 'n/a' > ${SWAPWRITEFILE}
type -p vmstat > /dev/null || { logError "'vmstat' utility is not installed, swap metrics will be unavailable"; exit 1; }

while true; do
  # ::::::::::: swap i/o
  # $ vmstat --no-first
  # procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
  # r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
  # 1  0 3314100 363380  30040 607636   4    0   132    48 2013 3409  3  1 96  0  0
  vmstat --no-first --unit K | tail -1 > ${TMPFILE}
  awk '{
        if ($7 < 1000)
          {VALUE = $7; UNIT = "KiB"; FORMAT = "%d%s"}
        else 
          {VALUE = $7/1024; UNIT = "MiB"; FORMAT = "%3.1f%s"}
       } 
       END {printf FORMAT, VALUE, UNIT}' ${TMPFILE} > ${SWAPREADFILE}.$$
  awk '{
        if ($8 < 1000)
          {VALUE = $8; UNIT = "KiB"; FORMAT = "%d%s"}
        else 
          {VALUE = $8/1024; UNIT = "MiB"; FORMAT = "%3.1f%s"}
       } 
       END {printf FORMAT, VALUE, UNIT}' ${TMPFILE} > ${SWAPWRITEFILE}.$$
  # ::::::::::: cpu
  awk '{print $13}' ${TMPFILE} > ${CPUUSFILE}.$$
  awk '{print $14}' ${TMPFILE} > ${CPUSYFILE}.$$
  awk '{print $15}' ${TMPFILE} > ${CPUIDFILE}.$$
  awk '{print $16}' ${TMPFILE} > ${CPUWAFILE}.$$
  
  renameTempFile ${SWAPREADFILE} ${SWAPWRITEFILE} ${CPUUSFILE} ${CPUSYFILE} ${CPUIDFILE} ${CPUWAFILE}
  sleep 1 &
  wait
done

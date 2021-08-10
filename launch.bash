#!/bin/bash

function usage() {
  echo >&2 "$(basename $0) --[laptop|desktop]"
}

# verify proper arguments were provided
if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

case $1 in
  --laptop)
    directory=~/conky/monochrome/small
    numCores=1
    ;;
  --desktop)
    directory=~/conky/monochrome/large
    numCores=7
    ;;
  *)  
    usage
    exit
    ;;
esac

echo -e "launching conky with the following settings:\n"
echo    "configuration folder: ${directory}"
echo -e "cpu load avg iddle:   ${numCores}\n"
echo    "the dnf package lookup will be executed if the 5 minute cpu load average is below $numCores"

killall conky
killall dnfPackageLookup.bash

IFS=$'\n' 
for conkyConfig in $(find "${directory}" -maxdepth 1 -type f -not -name '*.*')
do
  echo "Launching conky config '${conkyConfig}'"
  conky -c "${conkyConfig}" &
done

# prepare dnf package lookup file
# this file is read by conky to get the number of package updates, see dnfPackageLookup.bash
echo ':: stand by ::' > /tmp/conkyDnf
~/conky/monochrome/dnfPackageLookup.bash ${numCores} &

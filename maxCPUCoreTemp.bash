#! /bin/bash

# TODO support fractions

function usage {
  cat <<-END
	usage: $(basename $0) deviceName

	provide the name of the hwmon device that posts the cpu core temperatures
	typically the name is 'coretemp', run the command

	    cat /sys/class/hwmon/hwmon*/name

	to find the name for your system
	END
}

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 1
fi

hwmonPath=$(grep -w "$1" /sys/class/hwmon/hwmon*/name)

if [[ $hwmonPath ]]; then
    hwmon=${hwmonPath%/*}     # removes /name
    hwmon=${hwmon##*hwmon/}   # removes /sys/class/hwmon/
  else
    echo "no hwmon device found for ${1}" >&2
    exit 1
fi

echo 'cpu cores in this system'
cat /sys/class/hwmon/${hwmon}/temp*_label > /tmp/coreTemp-cores
cat /sys/class/hwmon/${hwmon}/temp*_input > /tmp/coreTemp-temps
paste /tmp/coreTemp-cores /tmp/coreTemp-temps

IFS_BAK=${IFS}
IFS=$'\n'
temperatures=($(cat /sys/class/hwmon/${hwmon}/temp*_input))
IFS=${IFS_BAK}

max=0     # max temperature

for temp in ${temperatures[@]}
do  
  temperature=${temp:0:2}
  
  if [[ $temperature -gt $max ]]; then
    max=$temperature
  fi
done

echo $max

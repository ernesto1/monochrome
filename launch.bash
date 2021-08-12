#!/bin/bash
source conkyLibrary.bash

function usage() {
  cat <<-END
	$(basename $0) --[mode] [monitor width]
	
	Options
	  --laptop
	    Loads the conky laptop mode.  Meant for monitors with a 1366 x 768 pixel resolution.

	  --desktop 1920|2560
	    Loads the conky desktop mode for the given resolution: 1920x1200 or 2560x1600.
	
	Examples
	  $(basename $0) --laptop
	  $(basename $0) --desktop 1920
	  $(basename $0) --desktop 2560
	END
}

# determine mode from the parameters provided
case $1 in
  --laptop)
    directory=${HOME}/conky/monochrome/small
    numCores=1
    screenWidth=1366
    ;;
  --desktop)
    directory=${HOME}/conky/monochrome/large
    numCores=7
    screenWidth=$2

    # ensure a supported monitor width was provided
    if [[ $screenWidth -ne 1920 ]] && [[ $screenWidth -ne 2560 ]]; then
      usage
      exit 1
    fi
    ;;
  *)            # this will also cover the use case of no arguments provided
    usage
    exit
    ;;
esac

echo -e "launching conky with the following settings:\n"
echo    "configuration folder: ${directory}"
echo    "monitor width:        ${screenWidth} pixels"
echo -e "cpu load avg iddle:   ${numCores}\n"
echo    "the dnf package lookup will be executed if the 5 minute cpu load average is below $numCores"

layoutFile="$(echo ${directory}/layout.${screenWidth}x*.cfg)"   # need to use echo in order for the variable
                                                                # to hold the actual pathname expansion

if [[ -f ${layoutFile} ]]; then
  echo -e "\noverriding conky layout as per ${layoutFile}"
  loadOverrideMap "${layoutFile}"
  
  # print layout override map
  #for key in ${!layoutMap[@]};
  #do
  #  echo ""${key}" | ${layoutMap["${key}"]}"
  #done  
fi

killall conky
killall dnfPackageLookup.bash

old_ifs="${IFS}"     # store IFRS for later use
IFS=$'\n'

for conkyConfig in $(find "${directory}" -maxdepth 1 -type f -not -name '*.*')
do
  echo -e "\nlaunching conky config '${conkyConfig##*/}'"
  key=${conkyConfig##*/}

  if [[ ${layoutMap[${key}]} ]]; then
    IFS="${old_ifs}"
    # override is of the format: 'x y alignment'
    #                            '10 50 top_right'  < space separated string
    layoutOverride=(${layoutMap[${key}]})     # create an array out of the string in order to have it word split
    # TODO ensure # of override elements is 2 or 3 elements
    # construct the position parameters for conky, ie. -x 10 -y 50 -a top_right
    alignment="${layoutOverride[2]}"    # optional field, may not exist
    layoutOverride=(-x "${layoutOverride[0]}" -y "${layoutOverride[1]}")
    
    # if alignment is provided, add -a flag
    if [[ "${alignment}" ]]; then
      layoutOverride=("${layoutOverride[@]:0:4}" -a "${alignment}")   # array index 0:4 is exclusive of the last element
    fi
    
    echo "applying the position override: ${layoutOverride[@]}"
  fi

  conky -c "${conkyConfig}" ${layoutOverride[@]} &
  unset layoutOverride
  IFS=$'\n'
done

# prepare dnf package lookup file
# this file is read by the 'system' conky to get the number of package updates, see dnfPackageLookup.bash
echo ':: stand by ::' > /tmp/conkyDnf
~/conky/monochrome/dnfPackageLookup.bash ${numCores} &

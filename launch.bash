#!/bin/bash
# script to launch a conky configuration for a particular mode/resolution
# the 'mode' (laptop/desktop) determines the target folder where all the conky configs will be loaded from
#
# position override
# an alignment override file can be used to move the conkys around from their default setup
# this is the case for the desktop 1920x1200 resolution, which takes advantage of this feature
#
# alignment override files must follow the naming convention: layout.<width>x<height>.cfg, ex. layout.1920x1200.cfg
# the override file must be placed in the target folder

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

# exits the script on error if the override file has any duplicate entries for a particular conky configuration
function detectDuplicateEntries() {
  # remove comment lines '#' and empty lines from the file, then look for dupes
  duplicates=$(grep -v \# $1 | grep -v '^$' | cut -d: -f1 | sort | uniq -d)
  
  if [[ $duplicates ]]; then
    echo 'Invalid override file.  Duplicate entry found.' >&2
    exit 2
  fi
}

# determine mode from the parameters provided
case $1 in
  --laptop)
    directory=${HOME}/conky/monochrome/small
    screenWidth=1366
    ;;
  --desktop)
    directory=${HOME}/conky/monochrome/large
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
echo    "conky folder:         ${directory}"
echo    "monitor width:        ${screenWidth} pixels"

layoutFile="$(echo ${directory}/layout.${screenWidth}x*.cfg)"   # need to use echo in order for the variable
                                                                # to hold the actual pathname expansion
if [[ -f ${layoutFile} ]]; then
  echo -e "layout override file: ${layoutFile}"
  detectDuplicateEntries "${layoutFile}"
  # TODO ensure # of override elements is 2 or 3 elements
fi

killall conky
killall dnfPackageLookup.bash

IFS=$'\n'

# all available conky configs in the target directory will be launched
# config file names are expected to not have an extension, ie. cpu vs cpu.cfg
# if an alignment override is available for the specific config, it will be used
for conkyConfig in $(find "${directory}" -maxdepth 1 -type f -not -name '*.*')
do
  echo -e "\nlaunching conky config '${conkyConfig##*/}'"
  [[ -f ${layoutFile} ]] && override=$(grep -v \# "${layoutFile}" | grep "${conkyConfig##*/}":)

  if [[ ${override} ]]; then
    # override is of the format: configFilename:x:y:alignment
    #                            cpu:10:50:top_right
    IFS=:
    layoutOverride=(${override})     # create an array out of the string in order to have it word split    
    # construct the position parameters for conky, ie. -x 10 -y 50 -a top_right
    alignment="${layoutOverride[3]}"    # optional field, may not exist
    layoutOverride=(-x "${layoutOverride[1]}" -y "${layoutOverride[2]}")
    
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
~/conky/monochrome/dnfPackageLookup.bash &

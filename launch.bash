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
	$(basename $0) --mode [--monitor 1|2|3|...] [--layout-override width]
	
	Mode options
	  --laptop
	    Loads the conky laptop theme.  Meant for monitors with a 1366 x 768 pixel resolution.

	  --desktop
	    Loads the conky desktop theme.  Meant for monitors with a 2560 x 1600 pixel resolution.
	    
	  --blame
	    Load the conky blame theme.

	Optional flags
	  --monitor 0|1|2|3|...
	    On multi monitor setups, use this flag to specify on which monitor you would like conky
	    to draw itself.
	    
	                 +--------+
	    +-----------+|        |
	    |           ||        |   How your monitors get assigned their number depends
	    |     0     ||   1    |   on the compositor you are running: x11 or wayland
	    |           ||        |   ie. monitor 0 may not be the same on both compositors
	    +-----------+|        |
	         |  |    +--------+
	        /    \      /  \\

	  --layout-override width
	    Allows you to use a layout override file in order to modify the position of the conkys on the fly.

	Examples
	  $(basename $0) --laptop
	  $(basename $0) --desktop
	  $(basename $0) --desktop --monitor 2
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

# ---------- script begins
set -e      # exit the script on an error

# ensure at least one parameter was provided
if [[ $# < 1 ]]; then
  usage
  exit 1
fi

while (( "$#" )); do
  case $1 in
    --blame)
      directory=${HOME}/conky/monochrome/blame
      shift
      ;;
    --desktop)
      directory=${HOME}/conky/monochrome/large
      shift
      ;;
    --laptop)
      directory=${HOME}/conky/monochrome/small
      shift
      ;;      
    --monitor)
      # TODO validate a proper number was provided to the monitor flag
      monitor=$2
      shift 2
      ;;
    --layout-override)
      screenWidth=$2
      
      if [[ -z $screenWidth ]]; then
        echo -e 'error | missing argument: screen width must be provided with the --layout-override flag\n\n' >&2
        usage
        exit 2
      fi
      
      shift 2
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

echo -e "launching conky with the following settings:\n"
echo    "conky folder:         ${directory}"

if [[ ${monitor} ]]; then
  echo    "window compositor:    $(echo $XDG_SESSION_TYPE)"
  echo    "monitor:              ${monitor}"
fi

if [[ ! -z $screenWidth ]]; then
  layoutFile="$(echo ${directory}/layout.${screenWidth}x*.cfg)"   # need to use echo in order for the variable
                                                                  # to hold the actual pathname expansion
  if [[ -f ${layoutFile} ]]; then
    echo -e "layout override file: ${layoutFile}"
    detectDuplicateEntries "${layoutFile}"
    # TODO file integrity: ensure number of override elements is 2 or 3
  else
    echo -e "\nerror | override file '${layoutFile}' not found" >&2
    echo      '        please provide a proper monitor width resolution and try again' >&2
    exit 2
  fi
fi

set +e      # ignore errors
killall conky
killall dnfPackageLookup.bash

IFS=$'\n'

# all available conky configs in the target directory will be launched
# config file names are expected to not have an extension, ie. cpu vs cpu.cfg
for conkyConfig in $(find "${directory}" -maxdepth 1 -type f -not -name '*.*')
do
  echo -e "\nlaunching conky config '${conkyConfig##*/}'"
  
  # 1. layout override
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

  # 2. monitor override
  if [[ $monitor ]]; then
    sed -i "s/xinerama_head *= *[[:digit:]]/xinerama_head = ${monitor}/" ${conkyConfig}
  fi

  # 3. launch conky
  conky -c "${conkyConfig}" ${layoutOverride[@]} &
  unset layoutOverride
  IFS=$'\n'
done

# prepare dnf package lookup file
# this file is read by the 'system' conky to get the number of package updates, see dnfPackageLookup.bash
echo ':: stand by ::' > /tmp/conkyDnf
~/conky/monochrome/dnfPackageLookup.bash &

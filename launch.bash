#!/bin/bash
# script to launch a conky configuration for a particular mode/resolution
# the 'mode' (laptop/desktop) determines the target folder where all the conky configs will be loaded from
#
# layout override
# ---------------
# a layout override file can be used to move the conkys around from their configured position in the conky config
# or filter out conkys you do not wish to load
#
# - the alignment override file must follow the naming convention: layout.<tag>.cfg, ex. layout.laptop.cfg
# - the tag is provided by the user at runtime with the --layout-override flag
# - the override file must exist in the conky target folder

function usage() {
  cat <<-END
	$(basename $0) --mode [--monitor n] [--layout-override tag] [--silent]
	
	Mode options
	These are the conky themes available
	  --laptop
	    Loads the conky widgets laptop theme.  Designed for monitors with a 1366 x 768 pixel resolution.

	  --desktop
	    Loads the conky widgets desktop theme.  Designed for monitors with a 2560 x 1600 pixel resolution.
	    
	  --blame
	  --glass    
    --compact
	
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

	  --layout-override tag
	    allows you to use a layout override file in order to modify the position of the conkys on the fly
	    override file follows the naming convention: layout.<tag>.cfg

	Examples
	  $(basename $0) --laptop
	  $(basename $0) --desktop --monitor 2
	  $(basename $0) --glass --monitor 1 --layout-override desktop --silent
	END
}

# exits the script on error if the override file has any duplicate entries for a particular conky configuration
function detectDuplicateEntries() {
  # remove comment lines '#', empty lines and 'ignore' entries from the file, then look for dupes
  duplicates=$(grep -vE '#|^$|ignore' $1 | cut -d: -f1 | sort | uniq -d)
  
  if [[ $duplicates ]]; then
    echo 'error | invalid override file,  duplicate entry found' >&2
    exit 2
  fi
}

# wrapper function to launch a conky config
# it allows you to call the function with output redirection if required (see the --silent flag)
function launchConky() {
  conky -c "$@" &
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
    --glass)
      directory=${HOME}/conky/monochrome/glass
      shift
      ;;
    --compact)
      directory=${HOME}/conky/monochrome/compact
      shift
      ;;
    --monitor)
      # TODO validate a proper number was provided to the monitor flag
      monitor=$2
      shift 2
      ;;
    --layout-override)
      fileTag=$2
      
      if [[ -z $fileTag ]]; then
        echo -e 'error | missing argument: override file tag must be provided with the --layout-override flag\n\n' >&2
        usage
        exit 2
      fi
      
      shift 2
      ;;
    --silent)
      silent=true
      shift
      ;;
    -h)
      usage
      exit
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

echo -e "::: launching conky with the following settings"
echo    "conky folder:         ${directory}"

if [[ ${monitor} ]]; then
  echo  "window compositor:    $(echo $XDG_SESSION_TYPE)"
  echo  "monitor:              ${monitor}"
fi

if [[ ! -z $fileTag ]]; then
  layoutFile="$(echo ${directory}/layout.${fileTag}.cfg)"   # need to use echo in order for the variable
                                                                  # to hold the actual pathname expansion
  if [[ -f ${layoutFile} ]]; then
    echo "layout override file: ${layoutFile}"
    detectDuplicateEntries "${layoutFile}"
    # TODO file integrity: ensure number of override elements is 2 or 3
  else
    echo -e '\nerror | override file '${layoutFile}' not found' >&2
    echo      '        please provide the proper override file name tag' >&2
    exit 2
  fi
fi

set +e      # ignore errors
echo -e '\n::: killing any currently running conky processes (listed below)'
echo -e 'PID   conky'
ps -fC conky | awk '{if (NR!=1) print $2,$10}'
killall conky
killall dnfPackageLookup.bash
sleep 1s      # waiting a bit in order to capture the STDOUT of the 'dnfPackageLookup.bash' script
              # it tends to print right below the 'launching conky' banner below

echo -e "\n::: launching conky configs"
IFS=$'\n'

# all available conky configs in the target directory will be launched
# config file names are expected to not have an extension, ie. cpu vs cpu.cfg
for conkyConfigPath in $(find "${directory}" -maxdepth 1 -not -name '*.*' -not -type d)
do
  conkyConfig=${conkyConfigPath##*/}    # remove the file path /home/ernesto/monochrome/.. from the file name
  echo "- ${conkyConfig}"
  # 1. filter out conky override
  #    override is of the format: ignore:<conkyFilename>
  #                           ex. ignore:externalDevices
  [[ -f ${layoutFile} ]] && ignore=$(grep -v \# "${layoutFile}" | grep ignore:"${conkyConfig}")
  
  if [[ ${ignore} ]]; then
    echo '  ignoring this conky due to it being in the exclusion list of the layout file'
    continue
  fi
  
  # 2. layout override
  #    override is of the format: conkyFilename:x:y:alignment
  #                               cpu:10:50:top_right
  [[ -f ${layoutFile} ]] && override=$(grep -v \# "${layoutFile}" | grep "${conkyConfig}":)

  if [[ ${override} ]]; then    
    IFS=:
    layoutOverride=(${override})      # create an array out of the string in order to have it word split    
    # construct the position parameters for conky, ie. -x 10 -y 50 -a top_right
    alignment="${layoutOverride[3]}"  # optional field, may not exist
    layoutOverride=(-x "${layoutOverride[1]}" -y "${layoutOverride[2]}")
    
    # if alignment is provided, add -a flag
    if [[ "${alignment}" ]]; then
      layoutOverride=("${layoutOverride[@]:0:4}" -a "${alignment}")   # array index 0:4 is exclusive of the last element
    fi
    
    echo "  applying the position override: ${layoutOverride[@]}"
  fi

  # 3. monitor override
  if [[ $monitor ]]; then
    sed -i "s/xinerama_head *= *[[:digit:]]/xinerama_head = ${monitor}/" ${conkyConfigPath}
  fi

  # 4. launch conky
  if [[ $silent ]]; then
    launchConky "${conkyConfigPath}" ${layoutOverride[@]} 2> /dev/null
  else
    launchConky "${conkyConfigPath}" ${layoutOverride[@]}
  fi  
  
  unset layoutOverride    # clear the variable for the next iteration, we don't want to run an override
                          # for the wrong conky
  IFS=$'\n'
done

echo -e "\n::: starting dnf package lookup service"
# prepare dnf package lookup file
# this file is read by the 'system' conky to get the number of package updates, see dnfPackageLookup.bash
echo ':: stand by ::' > /tmp/conkyDnf
~/conky/monochrome/dnfPackageLookup.bash &

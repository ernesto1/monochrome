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
# - the tag is provided by the user at runtime with the --layout-override someTag
# - the override file must exist in the conky target folder

shopt -s extglob    # enable extended globs for filename pattern matching
. ~/conky/monochrome/logging.bash

function usage() {
  cat <<-END
	$(basename $0) --theme [--monitor n] [--layout-override <tag>] [--silent] [--shutdown]
	
	Theme options
	  --compact
	  --glass
	  --widgets
	  --widgets-dock
	
	Optional flags
	  --monitor 0|1|2|3|...
	    On multi monitor setups, use this flag to specify on which monitor you would like conky
	    to draw itself.
	    
	                   +--------+
	    +-----------+  |        |
	    |           |  |        |   How your monitors get assigned their number depends
	    |     0     |  |    1   |   on the compositor you are running: x11 or wayland
	    |           |  |        |   ie. monitor 0 may not be the same on both compositors
	    +-----------+  |        |
	         |  |      +--------+
	        /    \        /  \\

	  --layout-override tag
	    allows you to use a layout override file in order to modify the position of the conkys on the fly.
	    conkys in the target directory can also be excluded from being loaded, ex. you have a conky that
	    you would like to run on your laptop but not on your desktop

	    override file follows the naming convention: layout.<tag>.cfg
	    
	  --silent
	    all conky output (STDOUT and STDERR) is suppressed
	  
	  --shutdown
	    kills the current running monochrome conkys and any support jobs launched

	Examples
	  $(basename $0) --widgets-dock
	  $(basename $0) --compact --monitor 2
	  $(basename $0) --glass --monitor 1 --layout-override desktop --silent
	END
}

# prints the line with color
# see https://opensource.com/article/19/9/linux-terminal-colors for more colors
function printHeader {
  printf "${GREEN}$1${NOCOLOR}\n"
}

# kills the monochrome conky and related support jobs that are currently running (if any)
function killSession {
  printHeader '\n::: killing the currently running processes of this conky suite\n'
  pgrep -f 'conky/monochrome' -l -a | sed 's/ /:/' | column -s ':' -t -N PID,process
  echo -e "\nclosing remarks"
  pkill -f 'conky/monochrome'
  sleep 1s  # wait a bit in order to capture the STDOUT of the 'dnfPackageLookup.bash' script
            # it tends to print right below the 'launching conky' banner below  
}

# exits the script on error if the override file has any duplicate entries for a particular conky configuration
function detectDuplicateEntries {
  # remove comment lines '#', empty lines and 'ignore' entries from the file, then look for dupes
  duplicates=$(grep -vE '#|^$|ignore' $1 | cut -d: -f1 | sort | uniq -d)
  
  if [[ $duplicates ]]; then
    echo 'invalid override file, duplicate entry found' >&2
    exit 2
  fi
}

# ---------- script begins

# ensure at least one parameter was provided
if [[ $# < 1 ]]; then
  usage
  exit 1
fi

# define default variables
monochromeHome=~/conky/monochrome
# enable/disable supporting scripts/java apps
enablePackageLookup=true
enableMusicPlayerListener=true
enableTransmissionPoller=true

while (( "$#" )); do
  case $1 in
    --widgets)
      shift
      conkyDir=${monochromeHome}/widgets
      numCharacters=24
      enableMusicPlayerListener=false
      enableTransmissionPoller=false
      ;;
    --widgets-dock)
      shift
      conkyDir=${monochromeHome}/widgets-dock
      ;;
    --glass)
      shift
      conkyDir=${monochromeHome}/glass
      numCharacters=25
      offset=10
      ;;
    --compact)
      shift
      conkyDir=${monochromeHome}/compact
      enableTransmissionPoller=false
      ;;
    --monitor)
      # TODO validate a proper number was provided to the monitor flag
      monitor=$2
      shift 2
      ;;
    --layout-override)
      fileTag=$2
      
      if [[ -z $fileTag ]]; then
        echo 'override file tag must be provided with the --layout-override flag' >&2
        echo -e '\n'
        usage
        exit 2
      else
        layoutFile="$(echo ${conkyDir}/layout.${fileTag}.cfg)"   # need to use echo in order for the variable
                                                                 # to hold the actual pathname expansion
        if [[ ! -f ${layoutFile} ]]; then
          echo "layout override file '${layoutFile}' not found" >&2
          echo 'please provide the proper override file name tag' >&2
          exit 2
        fi
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
    --shutdown)
      killSession
      exit
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

printHeader "::: launching conky with the following settings\n"
echo   "conky theme:          $(basename ${conkyDir})"
echo   "dnf package service:  ${enablePackageLookup}"
echo   "music player service: ${enableMusicPlayerListener}"
echo   "transmission service: ${enableTransmissionPoller}"

if [[ ${monitor} ]]; then
  echo "window compositor:    $(echo $XDG_SESSION_TYPE)"
  echo "monitor:              ${monitor}"
fi

if [[ ! -z ${layoutFile} ]]; then
  echo "layout override file: ${layoutFile}"
  detectDuplicateEntries "${layoutFile}"
  # TODO file integrity: ensure number of override elements is 2 or 3
fi

killSession
printHeader "\n::: launching conky configs\n"

# all available conky configs in the target directory will be launched
# config file names are expected to not have an extension, ie. cpu vs cpu.cfg
for conkyConfigPath in ${conkyDir}/!(*.*)
do
  [ -f "${conkyConfigPath}" ] || continue
  conkyConfig=${conkyConfigPath##*/}    # remove the path ${monochromeHome}/.. from the file name
  echo "- ${conkyConfig}"
  # 1. conky exclusion override, ie. exclude a configuration from being loaded
  #    override is of the format: ignore:<conkyFilename>
  #                           ex. ignore:externalDevices
  [[ -f ${layoutFile} ]] && ignore=$(grep -v \# "${layoutFile}" | grep ignore:"${conkyConfig}"$)
  
  if [[ ${ignore} ]]; then
    echo -e "  ${ORANGE}ignoring${NOCOLOR} this conky since it is in the exclusion list of the layout file"
    continue
  fi
  
  # 2. layout override
  #    override is of the format: conkyFilename:x:y:alignment
  #                               cpu:10:50:top_right
  [[ -f ${layoutFile} ]] && override=$(grep -v \# "${layoutFile}" | grep ^"${conkyConfig}":)

  if [[ ${override} ]]; then
    IFS_bk=${IFS} IFS=:
    layoutOverride=(${override})      # create an array out of the string in order to have it word split
    IFS=${IFS_bk}
    # construct the position parameters for conky, ie. -x 10 -y 50 -a top_right
    alignment="${layoutOverride[3]}"  # optional field, may not exist
    layoutOverride=(-x "${layoutOverride[1]}" -y "${layoutOverride[2]}")
    
    # if alignment is provided, add -a flag
    if [[ "${alignment}" ]]; then
      layoutOverride=("${layoutOverride[@]:0:4}" -a "${alignment}")   # array index 0:4 is exclusive of the last element
    fi
    
    echo "  applying the position override: ${layoutOverride[@]}"
    arguments=(${layoutOverride[@]})
    unset layoutOverride      # clear the array for the next iteration
  fi

  # 3. monitor/screen override
  if [[ $monitor ]]; then
    sed -i "s/xinerama_head *= *[[:digit:]]/xinerama_head = ${monitor}/" ${conkyConfigPath}
  fi

  # 4. silence conky output
  if [[ $silent ]]; then
    arguments+=(--quiet)
  fi
  
  # patch | some conky's are overlayed on top of others, in order for this to render correctly
  #         these conkys have to be executed last.  We launch these conkys with a delay.
  if [[ -n $(echo $conkyConfig | grep -E 'memory.+|temperature') ]]; then
    echo '  delaying conky by 1 second'
    arguments+=('--pause' 1)
  fi
  
  conky -c ${conkyConfigPath} "${arguments[@]}" &
  unset arguments
done

printHeader "\n::: starting support services\n"

# :: bash scripts

if ${enablePackageLookup}; then
  echo "- bash | dnf package updates service"

  if [[ "${numCharacters}" ]]; then
    arguments=(--package-width ${numCharacters})
  fi
  
  if [[ "${offset}" ]]; then
    arguments+=(--offset ${offset})
  fi

  ${monochromeHome}/dnfPackageLookup.bash ${arguments[@]} &
  unset arguments
fi

if ${enableTransmissionPoller}; then
  echo "- bash | transmission bittorrent service"
  echo -e "         ${ORANGE}ensure${NOCOLOR} the ${ORANGE}remote control${NOCOLOR} option is enabled in transmission"
  
  if [[ "${numCharacters}" ]]; then
    arguments=(--name-width ${numCharacters})
  fi
  
  if [[ "${offset}" ]]; then
    arguments+=(--offset ${offset})
  fi
  
  ${monochromeHome}/transmission.bash "${arguments[@]}" &
  unset arguments
fi

# :: java applications
msg="the java JDK is not installed on this system, unable to launch the java applications\n      some conkys will not work properly"
type java > /dev/null 2>&1 || { logError "$msg"; exit 1; }

if ${enableMusicPlayerListener}; then
  echo "- java | now playing music service"
  musicJar=(${monochromeHome}/java/music-player-*.jar)
  
  if [[ -f "${musicJar[0]}" ]]; then
    java -jar ${musicJar[0]} &   # if multiple jars are available, one will be picked at random
  else
    msg="the music player jar has not been compiled and deployed to the ${monochromeHome}/java directory\n"
    msg="${msg}      the 'now playing' conky will not work properly"
    logError $msg
  fi
fi

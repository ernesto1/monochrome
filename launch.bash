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
	$(basename $0) --conky theme [--monitor n] [--layout-override <tag>] [--silent] [--interval x] [--shutdown]
	
	Required flags
	  --conky $(cd ${monochromeHome}; echo !(builder|images|java|*.*) | tr ' ' '|')
	    select the theme to launch
	
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
	    applys any settings in a layout override file 

	      > changing the alignment of a conky
	      > excludes a particular conky in the theme from being launched 

	    the override file follows the naming convention: layout.<tag>.cfg

	  --silent
	    all conky output (STDOUT and STDERR) is suppressed

	  --interval 10m,1h,6h
	    wait time between package update queries, the default is 15 minutes
	    use a time period compatible with the sleep command, ex. 1h

	  --shutdown
	    kills the current running monochrome conkys and any supporting jobs launched

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

# kills any currently running monochrome conkys and support jobs
function killSession {
  printHeader '\n::: killing the currently running processes of this conky suite\n'
  pgrep -f 'conky/monochrome' -l -a | sed 's/ /:/' | column -s ':' -t -N PID,process
  printHeader "\nclosing remarks"
  pkill -f 'conky/monochrome'
  sleep 1s  # wait a bit in order to capture the STDOUT of the 'dnfPackageLookup.bash' script
            # it tends to print right below the 'launching conky' banner below  
}

# exits the script on error if the override file has any duplicate entries for a particular conky configuration
function detectDuplicateEntries {
  # remove comment lines '#', empty lines and 'ignore' entries from the file, then look for dupes
  duplicates=$(grep -vE '#|^$|ignore' $1 | cut -d: -f1 | sort | uniq -d)
  [[ $duplicates ]] && { logError 'invalid override file, duplicate entry found'; exit 2; }
}

# ---------- script begins
# define default variables
monochromeHome=${HOME}/conky/monochrome

(( $# < 1 )) && { usage; exit 1; }      # ensure at least one parameter was provided

while (( "$#" )); do
  case $1 in
    --conky)
      conkyDir=${monochromeHome}/${2}
      shift 2
      ;;
    --interval)
      interval=$2
      shift 2
      ;;
    --layout-override)
      fileTag=$2      
      [[ -z $fileTag ]] && { logError 'override file tag must be provided with the --layout-override flag'; exit 2;}
      shift 2
      ;;
    --monitor)
      # TODO validate a proper number was provided to the monitor flag
      monitor=$2
      shift 2
      ;;
    --no-torrent)
      isTransmissionPollerEnabled=false
      shift
      ;;
    --shutdown)
      killSession
      exit
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

[[ ${conkyDir} ]] || { logError 'a conky theme must be specified'; exit 1; }
[[ -d ${conkyDir} ]] || { logError "conky directory '$(basename ${conkyDir})' does not exist"; exit 1; }
[[ -f ${conkyDir}/settings.cfg ]] && source ${conkyDir}/settings.cfg

theme=$(basename ${conkyDir})
theme=${theme/-/ }
type -p figlet > /dev/null && echo -e "${GREEN}$(figlet -t ${theme} conky)\n"
printHeader "::: launching conky with the following settings\n"
echo   "conky theme:          ${theme}"
echo   "dnf package service:  ${isPackageLookupEnabled:=true}"
echo   "music player service: ${isMusicPlayerListenerEnabled:=true}"
echo   "transmission service: ${isTransmissionPollerEnabled:=true}"

if [[ ${monitor} ]]; then
  echo "window compositor:    $(echo $XDG_SESSION_TYPE)"
  echo "monitor:              ${monitor}"
fi

if [[ -n ${fileTag} ]]; then
  layoutFile=${conkyDir}/layout.${fileTag}.cfg
  echo "layout override file: ${layoutFile}"
  [[ -f ${layoutFile} ]] || { logError "layout override file 'layout.${fileTag}.cfg' not present in the conky directory"; exit 2;}
  detectDuplicateEntries "${layoutFile}"
  # TODO file integrity: ensure number of elements per override is 2 or 3
fi

killSession
printHeader "\n::: launching conky configs\n"

# all available conky configs in the target directory will be launched
# config file names are expected to not have an extension, ie. cpu vs cpu.cfg
for conkyConfigPath in ${conkyDir}/!(*.*)
do
  [ -f ${conkyConfigPath} ] || continue
  conkyConfig=${conkyConfigPath##*/}    # remove the path ${monochromeHome}/.. from the file name
  echo -n "- ${conkyConfig}"
  
  # 1. conky exclusion override: excludes a conky configuration from being loaded
  #    override is of the format: ignore:<conkyFilename>
  #                           ex. ignore:externalDevices
  if [[ -f ${layoutFile} ]] && grep -q "^ignore:${conkyConfig}$" ${layoutFile}; then
    echo ' [excluded]'
    continue
  else
    echo
  fi
  
  # 2. alignment override
  #    override is of the format: conkyFilename:x:y:alignment
  #                               cpu:10:50:top_right
  [[ -f ${layoutFile} ]] && override=$(grep ^"${conkyConfig}"\: ${layoutFile})

  if [[ ${override} ]]; then
    IFS=: layoutOverride=(${override})      # create an array out of the string in order to have it word split by bash
    # construct the position parameters for conky, ie. -x 10 -y 50 -a top_right
    alignment="${layoutOverride[3]}"  # optional field, may not exist
    layoutOverride=(-x "${layoutOverride[1]}" -y "${layoutOverride[2]}")
    # if alignment is provided, add the -a flag
    [[ ${alignment} ]] && layoutOverride+=(-a "${alignment}")
    echo "  applying the position override: ${layoutOverride[@]}"
    arguments=(${layoutOverride[@]})
  fi

  # 3. monitor/screen override
  [[ $monitor ]] && sed -i "s/xinerama_head *= *[[:digit:]]/xinerama_head = ${monitor}/" ${conkyConfigPath}
  # 4. silence conky output
  [[ $silent ]] && arguments+=(--quiet)
  
  # some conky's are overlayed on top of others, in order to render them correctly
  # these conkys have to be launched with a delay
  if [[ -f ${conkyDir}/settings.cfg ]] && grep -qw "delay:${conkyConfig}" ${conkyDir}/settings.cfg; then
    echo '  delaying conky by 1 second'
    arguments+=('--pause' 1)
  fi
  
  conky -c ${conkyConfigPath} "${arguments[@]}" &
  unset arguments
done

printHeader "\n::: starting support services\n"

# :: bash scripts
echo "- bash | advanced system performance metrics service"
${monochromeHome}/system.bash &

if ${isPackageLookupEnabled}; then
  echo "- bash | dnf package updates service"
  [[ "${numPackageCharacters}" ]] && arguments=(--package-width ${numPackageCharacters})
  [[ "${offsetPackage}" ]] && arguments+=(--offset ${offsetPackage})
  [[ "${interval}" ]] && arguments+=(--interval ${interval})
  ${monochromeHome}/dnfPackageLookup.bash ${arguments[@]} &
  unset arguments
fi

if ${isTransmissionPollerEnabled}; then
  echo "- bash | transmission bittorrent service"
  echo -e "         ${ORANGE}ensure${NOCOLOR} the ${ORANGE}remote control${NOCOLOR} option is enabled in transmission"  
  [[ "${format}" ]] && arguments=(--format ${format})
  [[ "${numTorrentCharacters}" ]] && arguments+=(--name-width ${numTorrentCharacters})
  [[ "${offsetTorrent}" ]] && arguments+=(--offset ${offsetTorrent})
  ${monochromeHome}/transmission.bash "${arguments[@]}" &
  unset arguments
fi

# :: java applications
msg="the java JDK is not installed on this system, unable to launch the java applications\n      the 'now playing' conky will not work properly"
type java > /dev/null 2>&1 || { logError "$msg"; exit 1; }

if ${isMusicPlayerListenerEnabled}; then
  echo "- java | now playing music service"
  musicJar=(${monochromeHome}/java/music-player-*.jar)
  
  if [[ -f "${musicJar[0]}" ]]; then
    java -jar ${musicJar[0]} &   # if multiple jars are available, one will be picked at random
  else
    msg="the music player jar has not been compiled and deployed to the ${monochromeHome}/java directory.  "
    msg+="The 'now playing' conky will not work properly."
    logError "$msg"
  fi
fi

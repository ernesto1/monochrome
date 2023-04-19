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

function usage() {
  cat <<-END
	$(basename $0) --theme [--monitor n] [--layout-override <tag>] [--silent]
	
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

	Examples
	  $(basename $0) --widgets-dock
	  $(basename $0) --compact --monitor 2
	  $(basename $0) --glass --monitor 1 --layout-override desktop --silent
	END
}

# exits the script on error if the override file has any duplicate entries for a particular conky configuration
function detectDuplicateEntries() {
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
enablePackageLookup=true          # dnf package lookup is enabled
enableMusicPlayerListener=false   # java music player dbus listener is disabled

while (( "$#" )); do
  case $1 in
    --widgets)
      directory=${HOME}/conky/monochrome/widgets
      width=32
      shift
      ;;
    --widgets-dock)
      directory=${HOME}/conky/monochrome/widgets-dock
      width=30
      enableMusicPlayerListener=true
      shift
      ;;
    --glass)
      directory=${HOME}/conky/monochrome/glass
      shift
      ;;
    --compact)
      directory=${HOME}/conky/monochrome/compact
      width=30
      enableMusicPlayerListener=true
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
        echo 'override file tag must be provided with the --layout-override flag' >&2
        echo -e '\n'
        usage
        exit 2
      else
        layoutFile="$(echo ${directory}/layout.${fileTag}.cfg)"   # need to use echo in order for the variable
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

if [[ ! -z ${layoutFile} ]]; then
  echo "layout override file: ${layoutFile}"
  detectDuplicateEntries "${layoutFile}"
  # TODO file integrity: ensure number of override elements is 2 or 3
fi

echo -e '\n::: killing the currently running processes of this conky suite'
pgrep -f 'conky/monochrome' -l -a | sed 's/ /:/' | column -s ':' -t -N PID,process
pkill -f 'conky/monochrome'
sleep 1s  # wait a bit in order to capture the STDOUT of the 'dnfPackageLookup.bash' script
          # it tends to print right below the 'launching conky' banner below
echo -e "\n::: launching conky configs"
IFS=$'\n'

# all available conky configs in the target directory will be launched
# config file names are expected to not have an extension, ie. cpu vs cpu.cfg
for conkyConfigPath in $(find "${directory}" -maxdepth 1 -not -name '*.*' -not -type d)
do
  conkyConfig=${conkyConfigPath##*/}    # remove the file path ~/conky/monochrome/.. from the file name
  echo "- ${conkyConfig}"
  # 1. conky exclusion override, ie. exclude a configuration from being loaded
  #    override is of the format: ignore:<conkyFilename>
  #                           ex. ignore:externalDevices
  [[ -f ${layoutFile} ]] && ignore=$(grep -v \# "${layoutFile}" | grep ignore:"${conkyConfig}"$)
  
  if [[ ${ignore} ]]; then
    echo '  ignoring this conky due to it being in the exclusion list of the layout file'
    continue
  fi
  
  # 2. layout override
  #    override is of the format: conkyFilename:x:y:alignment
  #                               cpu:10:50:top_right
  [[ -f ${layoutFile} ]] && override=$(grep -v \# "${layoutFile}" | grep ^"${conkyConfig}":)

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
  IFS=$'\n'
done

echo -e "\n::: start support services"

# using shell builtins
if "$enablePackageLookup"; then
  echo -e "\n- dnf package lookup service"

  if [[ "${width}" ]]; then
    dnfParameters=(--width ${width})
  fi

  ~/conky/monochrome/dnfPackageLookup.bash ${dnfParameters[@]} &
fi

if "$enableMusicPlayerListener"; then
  echo -e "\n- now playing music service"
  java -jar ~/conky/monochrome/java/music-player-*.jar &
fi

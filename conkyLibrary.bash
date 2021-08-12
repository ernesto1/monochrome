#! /bin/bash

# reads the given layout override file and creates a map/dictionary
# where the 'key' is the name of the conky config that has an override
#
# the method "returns" the map as a global variable called 'layoutMap'
# TODO instead of a global variable, return the actual map using the echo strategy
function loadOverrideMap() {
  local file=$1
  declare -g -A layoutMap             # must use -g in order for the map to have global scope

  while IFS=: read -r -a position
  do
    local conkyConfig="${position[0]}"
    unset "position[0]"
    layoutMap["${conkyConfig}"]="${position[*]}"  
  done < "${file}"
}

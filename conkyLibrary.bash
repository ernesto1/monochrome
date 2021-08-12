#! /bin/bash

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

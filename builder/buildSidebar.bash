#! /bin/bash

# usage:  buildSidebar.bash config file1 file2 file3
#
# description
# this script will build the conky sidebar by stacking the given configuration files.
# images in the input conky config files will have their 'y' coordinate as an offset.
# as each config file is processed, the 'y' coordinate is increased based on the images in the file.
#
# asumptions
# - first argument will be the 'config' file
# - images in the 'config' file are not taken into account for the vertical image offset calculation
#   while the sidebar is constructed
# - the conky height is determined by taking ALL images in the final conky file into account

# iterates through all the images in the file to determine the max height by considering:
#
# - the image's 'y' coordinate                  +------- img 1 ----+
# - the image's height                          |                  |
#                                               |   +- img 2 --+   |
#                                               |   |          |   |
#                                               |   |          |   |
#                                               |   |          |   |
#                                               |   +----------+   |
#                                               |                  |
#                                               |         +------+ |
#                                               |         | img3 | |
#                                               +---------|      |-+
#                                       max height >      +------+
#
function getMaxImageHeight {
  IFS=$'\n'
  local images=($(grep -E 'image.+-p' ${1}))
  IFS=${IFS_BAK}
  local maxHeight=0

  for imageVariable in "${images[@]}"
  do
    local REGEX='.+image (.+\.png) -p [[:digit:]]+,([[:digit:]]+)'
    
    if [[ $imageVariable =~ $REGEX ]]
    then
      #echo $imageVariable
      local dimensions=$(file $(echo "echo ${BASH_REMATCH[1]}" | bash) | grep -Eo '[[:digit:]]+ *x *[[:digit:]]+')
      local height=${dimensions#* x }
      local imageHeight=0
      ((imageHeight=${BASH_REMATCH[2]} + height))
      #echo "y: ${BASH_REMATCH[2]}  - image height: ${height}px - total height: ${imageHeight}px"
      
      if [[ imageHeight -gt maxHeight ]]
      then
        maxHeight=${imageHeight}
      fi
      
      #echo "max: $maxHeight"
    fi
  done
  
  echo ${maxHeight}
}


NOCOLOR='\033[0m'
ORANGE='\033[0;33m'
GREEN='\033[32m'
TEMP_FILE="/tmp/monochrome/sidebar.$$"
OUT_FILE="/tmp/monochrome/sidebar"

echo -e "${ORANGE}:::::::::: building conky sidebar${NOCOLOR}"
rm -f ${OUT_FILE}     # remove prior conky sidebar file if it exists
configFile=$1         # config file is the 1st argument
shift 1
currentHeight=0

for file in "$@"
do
  echo -e "${GREEN}>>> $file${NOCOLOR}"
  echo -e "starting height: $currentHeight px\n"
  cat $file >> ${TEMP_FILE}
  
  IFS_BAK=${IFS}
  IFS=$'\n'
  images=($(grep '${image ~' $file))
  IFS=${IFS_BAK}
  
  for imageVariable in "${images[@]}"
  do
    echo "- $imageVariable"
    # sample text to parse
    # ${image ~/conky/monochrome/images/widgets-dock/purple-power-charging.png -p 0,489}\
    # ${image ~/conky/monochrome/images/widgets-dock/yellow-edge-bottom.png -p 0,-10}\
    REGEX='.+image (.+\.png) -p ([[:digit:]]+),(-?[[:digit:]]+)'
  
    if [[ $imageVariable =~ $REGEX ]]
    then
      image=${BASH_REMATCH[1]}                    # ~/conky/monochrome/images/widgets-dock/image.png
      imagePath=$(echo "echo ${image}" | bash)    # translate the tilde '~' from the image's path
                                                  # the file command below can't read it for some reason
      #echo image: $imagePath
      xCoordinate=${BASH_REMATCH[2]}
      yCoordinate=${BASH_REMATCH[3]}
      ((newYCoordinate=yCoordinate+currentHeight))
      echo "  new coordinates: ${xCoordinate},${newYCoordinate}"
      sed -i "s#${image} -p ${xCoordinate},${yCoordinate}}#${image} -p ${xCoordinate},${newYCoordinate}}#" ${TEMP_FILE}
    fi
  done
  
  echo -en '\nending height: '
  currentHeight=$(getMaxImageHeight "${TEMP_FILE}")
  echo -e "$currentHeight px\n"
  rm $file
done

cat ${configFile} ${TEMP_FILE} > ${OUT_FILE}
rm ${configFile} ${TEMP_FILE}
echo -e "${ORANGE}:::::::::: sidebar adjustments${NOCOLOR}"
# update the conky height based on the image with tallest height
maxHeight=$(getMaxImageHeight "${OUT_FILE}")
sed -i "s/minimum_height *=.\+,/minimum_height = ${maxHeight},/" ${OUT_FILE}
echo -en "conky height updated to account for the largest image in the file:"
grep minimum_height ${OUT_FILE}

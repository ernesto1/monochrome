#! /bin/bash

# asumptions:
# - first file will be the config file
# - images in the config file are not accounted for offset of conky height calculations
# - images are placed sequentially, ie. the last image in the conky will determine the total height of the block
# TODO calulate the max height from all the images in the block instead

NOCOLOR='\033[0m'
ORANGE='\033[0;33m'
GREEN='\033[32m'
TEMP_FILE="/tmp/monochrome/sidebar.$$"
totalHeight=0

echo -e "${ORANGE}:::::::::: building conky sidebar${NOCOLOR}"
OUT_FILE="/tmp/monochrome/sidebar"
rm -f ${OUT_FILE}     # remove prior conky sidebar file if it exists
configFile=$1         # config file is the 1st argument
shift 1

for file in "$@"
do
  echo -e "${GREEN}>>> $file${NOCOLOR}"
  echo -e "starting height: $totalHeight px\n"
  cat $file >> ${TEMP_FILE}
  
  IFS_BAK=${IFS}
  IFS=$'\n'
  images=($(grep '${image ~' $file))
  IFS=${IFS_BAK}
  
  for imageVariable in "${images[@]}"
  do
    echo $imageVariable
    # sample text to parse
    # ${image ~/conky/monochrome/images/widgets-dock/purple-power-charging.png -p 0,489}\
    # ${image ~/conky/monochrome/images/widgets-dock/yellow-edge-bottom.png -p 0,-10}\
    REGEX='.+image (.+\.png) -p ([[:digit:]]+),(-?[[:digit:]]+)'
  
    if [[ $imageVariable =~ $REGEX ]]
    then
      image=${BASH_REMATCH[1]}                    # ~/conky/monochrome/images/widgets-dock/image.png
      imagePath=$(echo "echo ${image}" | bash)    # translate the tilde '~' from the image's path
                                                  # the file command below can't read it for some reason
      echo image: $imagePath
      xCoordinate=${BASH_REMATCH[2]}
      yCoordinate=${BASH_REMATCH[3]}
      ((newYCoordinate=yCoordinate+totalHeight))
      echo "new coordinates: ${xCoordinate},${newYCoordinate}"
      sed -i "s#${image} -p ${xCoordinate},${yCoordinate}}#${image} -p ${xCoordinate},${newYCoordinate}}#" ${TEMP_FILE}
      echo
    fi
  done
  
  echo '> using last image as reference for block height'
  dimensions=$(file "${imagePath}" | grep -Eo '[[:digit:]]+ *x *[[:digit:]]+')
  echo "dimensions:     $dimensions"
  height=${dimensions#* x }
  echo "height:         $height px"
  ((totalHeight=newYCoordinate+height))
  echo -e "current height: $totalHeight px\n"
  rm $file
done

cat config ${TEMP_FILE} > ${OUT_FILE}
rm $1 ${TEMP_FILE}
echo -e "${ORANGE}:::::::::: sidebar adjustments${NOCOLOR}"
# update the conky height based on the image with tallest height
IFS=$'\n'
images=($(grep -E 'image.+-p' ${OUT_FILE}))
IFS=${IFS_BAK}
maxHeight=0

for imageVariable in "${images[@]}"
do
  REGEX='.+image (.+\.png) -p [[:digit:]]+,([[:digit:]]+)'
  
  if [[ $imageVariable =~ $REGEX ]]
  then
    dimensions=$(file $(echo "echo ${BASH_REMATCH[1]}" | bash) | grep -Eo '[[:digit:]]+ *x *[[:digit:]]+')    
    height=${dimensions#* x }
    ((totalHeight=${BASH_REMATCH[2]} + height))
    
    if [[ totalHeight -gt maxHeight ]]
    then
      maxHeight=${totalHeight}
    fi
  fi
done

sed -i "s/minimum_height *=.\+,/minimum_height = ${maxHeight},/" ${OUT_FILE}
echo -e "conky height updated to"
grep minimum_height ${OUT_FILE}

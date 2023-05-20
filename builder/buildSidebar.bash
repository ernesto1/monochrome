#! /bin/bash

# asumptions:
# images are placed sequentially, ie. the last image in the conky will determine the total height of the block
# TODO calulate the max height from all the images in the block instead

NOCOLOR='\033[0m'
ORANGE='\033[0;33m'
GREEN='\033[32m'
OUT_FILE='/tmp/monochrome/sidebar'
totalHeight=0

echo -e "${ORANGE}:::::::::: building conky sidebar${NOCOLOR}"
rm -f ${OUT_FILE}     # remove prior conky version if it exists

for file in "$@"
do
  echo -e "${GREEN}>>> $file${NOCOLOR}"
  echo -e "starting height: $totalHeight px\n"
  cat $file >> ${OUT_FILE}
  
  IFS_BAK=${IFS}
  IFS=$'\n'
  images=($(grep '${image ~' $file))
  IFS=${IFS_BAK}
  
  for imageCommand in "${images[@]}"
  do
    echo $imageCommand
    # ${image ~/conky/monochrome/images/widgets-dock/purple-power-charging.png -p 0,489}\
    image=${imageCommand#*image }   # remove '${image '
    image=${image% -p *}            # remove ' -p 0,489}\'
    imagePath=$(echo "echo $image" | bash)
    #echo image: $imagePath    
    coordinates=$(echo ${imageCommand} | grep -Eo '[[:digit:]]+,-*[[:digit:]]+')
    echo "coordinates:     $coordinates"
    xCoordinate=${coordinates%,*}
    #echo x: $xCoordinate
    yCoordinate=${coordinates#*,}
    #echo y: $yCoordinate
    ((newYCoordinate=yCoordinate+totalHeight))
    echo "new coordinates: ${xCoordinate},${newYCoordinate}"
    sed -i "s#${image} -p ${xCoordinate},${yCoordinate}}#${image} -p ${xCoordinate},${newYCoordinate}}#" ${OUT_FILE}
    echo
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

echo -e "${ORANGE}:::::::::: sidebar adjustments${NOCOLOR}"
# update the sidebar height
sed -i "s/minimum_height *=.\+,/minimum_height = ${totalHeight},/" ${OUT_FILE}
echo -e "conky height updated to"
grep minimum_height ${OUT_FILE}

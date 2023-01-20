#! /bin/bash

# asumptions:
# - images are placed sequentially, ie. last image in the conky will determine the total height of the block

echo '::::::::::::: building conky sidebar'
totalHeight=0

rm -f /tmp/monochrome/sidebar     # remove prior conky version if it exists

for file in "$@"
do
  echo '>>>>' $file
  echo -e starting height: $totalHeight '\n'
  cat $file >> /tmp/monochrome/sidebar
  
  
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
    echo image: $imagePath    
    coordinates=$(echo ${imageCommand} | grep -Eo '[[:digit:]]+,-*[[:digit:]]+')
    echo coordinates: $coordinates
    xCoordinate=${coordinates%,*}
    echo x: $xCoordinate
    yCoordinate=${coordinates#*,}
    echo y: $yCoordinate
    ((newYCoordinate=yCoordinate+totalHeight))
    echo new y: $newYCoordinate    
    sed -i "s#${image} -p ${xCoordinate},${yCoordinate}}#${image} -p ${xCoordinate},${newYCoordinate}}#" /tmp/monochrome/sidebar
    echo
  done
  
  echo '> using last image as reference for block height'
  dimensions=$(file "${imagePath}" | grep -Eo '[[:digit:]]+ *x *[[:digit:]]+')
  echo dimensions: $dimensions
  height=${dimensions#* x }
  echo height: $height
  ((totalHeight=newYCoordinate+height))
  echo -e "current height: $totalHeight\n\n"
done

# update the sidebar height
sed -i "s/minimum_height *=.\+,/minimum_height = ${totalHeight},/" /tmp/monochrome/sidebar
echo -e "conky height updated to"
grep minimum_height /tmp/monochrome/sidebar

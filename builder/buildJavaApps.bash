#!/bin/bash
# builds and deployes the supporting java applications to the monochrome/java folder

set -e
shopt -s extglob

# build and deploy the java apps
ORANGE='\033[0;33m'; NOCOLOR='\033[0m'
printf "${ORANGE}:::::: building java applications${NOCOLOR}\n"
pushd ~/conky/monochrome/builder/java-tools
mvn clean package
popd
printf "\n${ORANGE}:::::: deploying java apps${NOCOLOR}\n"
mkdir -p ~/conky/monochrome/java
echo 'currently deployed jars:'
ls ~/conky/monochrome/java
rm -rf ~/conky/monochrome/java/!(albumArt)
cp -r ~/conky/monochrome/builder/java-tools/*/target/{lib,*.jar,*.yaml,*.xml} ~/conky/monochrome/java
echo -e '\nnewly deployed jars:'
ls ~/conky/monochrome/java
printf "\n${ORANGE}:::::: launching latest version of the music player app${NOCOLOR}\n"
pgrep -f 'conky/monochrome/java/music' -l -a | sed 's/ /:/' | column -s ':' -t -N PID,'processes to be killed'
echo
set +e
# pkill returns 1 if no processes matched
pkill -ef 'conky/monochrome/java/music'
java -jar ~/conky/monochrome/java/music-player-*.jar &

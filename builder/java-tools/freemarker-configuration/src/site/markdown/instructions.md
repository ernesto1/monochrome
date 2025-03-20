## How to generate conky configurations
Chose from one of the available conky collections:
```shell
$ cd ~/conky/monochrome/builder/freemarker
$ ls -1d !(lib)/
blocks/
classic/
compact/
glass/
widgets/
widgets-dock/
```
Chose a color schemes for it:
```shell
$ java -jar ~/conky/monochrome/java/freemarker-configuration-*.jar --conky blocks --colors
20:52:52.680 INFO  ConkyTemplate.main:56 - available color schemes: [baltimore, nelson, grape, 
green, hulk, ticonderoga, yellow, yotsuba]
```
Generate the conky configurations for the desired device and color scheme:
```shell
$ java -jar ~/conky/monochrome/java/freemarker-configuration-*.jar --conky blocks --color nelson --device desktop
INFO  ConkyTemplate.main:61 - generating configuration files out of the freemarker templates
INFO  ConkyTemplate.main:63 -        conky: blocks
INFO  ConkyTemplate.main:65 -       device: desktop
INFO  ConkyTemplate.main:67 -    isVerbose: true
INFO  ConkyTemplate.main:72 - color scheme: nelson
INFO  ConkyTemplate.main:100 - processing template files:
INFO  ConkyTemplate.main:104 - > transmission.ftl
INFO  ConkyTemplate.main:104 - > sidebar.ftl
```
The configurations are written to the collection's corresponding folder in the `~/conky/monochrome` directory.
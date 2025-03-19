## How to generate conky configurations
List the available conky collections:
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
See the available color schemes for a conky:
```shell
$ java -jar ~/conky/monochrome/java/freemarker-configuration-*.jar --conky blocks --colors
20:52:52.680 INFO  ConkyTemplate.main:56 - available color schemes: [baltimore, nelson, grape, 
green, hulk, ticonderoga, yellow, yotsuba]
```
Generate the conky configurations for the desired system and color scheme:
```shell
$ java -jar ~/conky/monochrome/java/freemarker-configuration-*.jar --conky blocks --color nelson --system desktop
20:56:26.810 INFO  ConkyTemplate.main:61 - creating configuration files for the 'blocks' conky
20:56:26.817 INFO  ConkyTemplate.main:65 - applying the 'nelson' color scheme
20:56:27.033 INFO  ConkyTemplate.main:89 - processing template files:
20:56:27.034 INFO  ConkyTemplate.main:93 - > bar.ftl
20:56:27.260 INFO  ConkyTemplate.main:93 - > transmission.ftl
20:56:27.274 INFO  ConkyTemplate.main:93 - > sidebar.ftl
```
The configurations are written to the `/tmp/monochrome` directory.
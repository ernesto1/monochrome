## How to generate conky configurations
Chose from one of the available conky collections:
```shell
$ java -jar ~/conky/monochrome/java/configuration-generator-1.18.0.jar --list
classic
bar
widgets-dock
glass
compact
blocks
widgets
```
Chose a color schemes for it:
```shell
$ java -jar ~/conky/monochrome/java/configuration-generator-*.jar --conky blocks --colors
available color schemes: [baltimore, nelson, grape, green, hulk, ticonderoga, yellow, yotsuba]
```
Generate the conky configurations for the desired device and color scheme:
```shell
$ java -jar ~/conky/monochrome/java/configuration-generator-*.jar --conky blocks --color green --device desktop
INFO  ConkyTemplate.main:61 - generating configuration files out of the freemarker templates
INFO  ConkyTemplate.main:63 -        conky: blocks
INFO  ConkyTemplate.main:65 -       device: desktop
INFO  ConkyTemplate.main:67 -    isVerbose: true
INFO  ConkyTemplate.main:72 - color scheme: green
INFO  ConkyTemplate.main:100 - processing template files:
INFO  ConkyTemplate.main:104 - > transmission.ftl
INFO  ConkyTemplate.main:104 - > sidebar.ftl
```
The configurations are written to the collection's corresponding folder in the `~/conky/monochrome` directory.
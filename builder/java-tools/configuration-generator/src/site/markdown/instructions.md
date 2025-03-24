## How to generate conky configurations
Chose from one of the available conky collections:
```shell
$ java -jar ~/conky/monochrome/java/configuration-generator-1.18.0.jar --list
collection   | color schemes
------------ | -------------
bar          | nelson, grape
blocks       | baltimore, nelson, grape, green, hulk, ticonderoga, yellow, yotsuba
classic      | grape, yellow, ticonderoga, nelson, zara
compact      | burgundy
glass        | blue, baltimore
widgets      | hulk, green
widgets-dock | grape, yellow, purple
```
Generate the conky configurations for the desired collection and color scheme:
```shell
$ java -jar ~/conky/monochrome/java/configuration-generator-*.jar --conky blocks --color green
INFO  ConkyTemplate.main:73 - generating configuration files for the following setup:
INFO  ConkyTemplate.main:75 - conky       : blocks
INFO  ConkyTemplate.main:77 - device      : desktop
INFO  ConkyTemplate.main:79 - isVerbose   : true
INFO  ConkyTemplate.main:82 - color scheme: green
INFO  ConkyTemplate.main:112 - processing template files:
INFO  ConkyTemplate.main:116 - > transmission.ftl
INFO  ConkyTemplate.main:116 - > sidebar.ftl
```
The configuration files are written to the collection's corresponding folder in the `~/conky/monochrome` directory.
## Freemarker templates
Conky configurations are generated using [Apache Freemarker Templates](https://freemarker.apache.org/).  Templates allow the designer to be able to:

- Programatically write conky script code
- Apply theming to a conky  
  ![conky with different color schemes](https://raw.githubusercontent.com/ernesto1/monochrome/refs/heads/master/images/screenshots/blocks.png)

- Generate a laptop or desktop version of the same conky  
  ![desktop vs laptop version](https://raw.githubusercontent.com/ernesto1/monochrome/refs/heads/master/builder/freemarker/system-differences.png)

### Conky Templates
The available templates for this project are under the `~/conky/monochrome/builder/freemarker` directory.  
Each sub directory is a collection of conkys under a specific theme.  Where each `.ftl` file is template that corresponds to a conky configuration.  
See the [How to use](instructions.html) page for a tutorial on how to build a conky configuration.
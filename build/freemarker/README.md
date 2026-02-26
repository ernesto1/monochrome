# Freemarker templates
Conky configurations are built using the [java freemarker engine](https://freemarker.apache.org/) via templates.

This allows me the flexibility to [create two different versions](dynamicSidebar.md) of the same conky depending on the system I'm targeting: desktop or laptop.

## Data model
The data model for the a conky template is composed of two parts:

- Hardware details
- Color palette, see the `colorPalette.yml` found on each individual conky folder

When a configuration is being built for a particular conky theme (ex. `compact` conky)
these two data models will be merged and used by the freemarker engine.

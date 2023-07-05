# Build assets
This directory contains the source code to build the different conky themes and the supporting applications.

### Conky configuration templates
Conkys are built using the [java freemarker engine](https://freemarker.apache.org/).  This allows me to:

- [Dynamically build conky sidebars](dynamicSidebar.md) based on the target device: desktop or laptop
- Change the conky color scheme
- See `java-tools/freemarker-configuration`, `buildSidebar.bash` and the `freemarker` directory

### Java applications
Supporting java applications will be under the `java-tools` maven project.

### Bug tracking
Any conky issues I've had to compensate for are tracking in this [log](bugLog.md).  
This may help explain why I had to make certain design decisions.
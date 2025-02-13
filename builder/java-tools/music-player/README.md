# Music Player D-Bus Listener
### Building the application
The application can be built from source by running the maven command
```bash
mvn clean package
```
It still has to be deployed to the `monochrome/java` directory for actual use by the launch script.  
The [buildJavaApps.bash](https://github.com/ernesto1/monochrome/blob/master/builder/buildJavaApps.bash) script 
was written to simplify this process.  It builds and deploys all the java applications to the target folder.

### Documentation
To generate the documentation for this application run the maven site command
```bash
mvn clean site
```
Open the file `target/site/index.html` in your web browser.
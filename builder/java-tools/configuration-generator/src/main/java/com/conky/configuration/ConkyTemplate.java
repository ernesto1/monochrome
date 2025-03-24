package com.conky.configuration;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateExceptionHandler;
import net.sourceforge.argparse4j.ArgumentParsers;
import net.sourceforge.argparse4j.impl.Arguments;
import net.sourceforge.argparse4j.inf.ArgumentGroup;
import net.sourceforge.argparse4j.inf.ArgumentParser;
import net.sourceforge.argparse4j.inf.MutuallyExclusiveGroup;
import net.sourceforge.argparse4j.inf.Namespace;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.yaml.snakeyaml.Yaml;

import java.io.*;
import java.util.Arrays;
import java.util.Map;

public class ConkyTemplate {
    private static final Logger logger = LoggerFactory.getLogger(ConkyTemplate.class);
    private static final File MONOCHROME_ROOT_DIR = new File(System.getProperty("user.home"), "conky/monochrome");
    /**
     * Root directory with the configuration files for all themes
     */
    private static final File TEMPLATE_ROOT_DIR = new File(MONOCHROME_ROOT_DIR, "builder/freemarker");
    private static final String COLOR_PALETTE_FILENAME = "colorPalette.yml";
    private static Yaml yaml = new Yaml();

    /**
     * Parses the conky freemarker template files based on the user inputs
     * @param args arguments to the java application
     * @throws IOException if an input file is not available
     * @throws TemplateException if a freemarker error occurs while processing the templates
     */
    public static void main(String[] args) throws TemplateException, IOException {
        Namespace namespace = processArguments(args);

        // if the --list argument was provided, list available conky collections and exit
        if (namespace.getBoolean("list")) {
            listConkyCollections();
            System.exit(0);
        }

        String conky = namespace.getString("conky");
        validateArguments(conky);
        String device = namespace.get("device").toString().toLowerCase();
        boolean isVerbose = ! namespace.getBoolean("nonverbose");
        logger.info("generating configuration files for the following setup:");
        String labelFormat = "%-12s: {}";
        String propertyFormat = String.format(labelFormat, "conky");
        logger.info(propertyFormat, conky);
        propertyFormat = String.format(labelFormat, "device");
        logger.info(propertyFormat, device);
        propertyFormat = String.format(labelFormat, "isVerbose");
        logger.info(propertyFormat, isVerbose);
        String color = namespace.getString("color");
        propertyFormat = String.format(labelFormat, "color scheme");
        logger.info(propertyFormat, color);

        // ::: create the freemarker data model
        // load hardware data model
        Map<String, Object> root = loadYamlConfig(new File(TEMPLATE_ROOT_DIR, "hardware-" + device + ".yml"));
        root.put("conky", conky);
        root.put("device", device);
        root.put("isVerbose", isVerbose);
        // load conky color palette
        File conkyTemplateDir = new File(TEMPLATE_ROOT_DIR, conky);
        File colorConfig = new File(conkyTemplateDir, COLOR_PALETTE_FILENAME);
        Map<String, Object> colorPalettes = loadYamlConfig(colorConfig);

        if (colorPalettes.containsKey(color)) {
            root.putAll((Map<String, Object>) colorPalettes.get(color));
            logger.debug("device + color scheme data model: {}", root);
        } else {
            logger.error("the '{}' color scheme is not configured for this conky, available colors are: {}",
                         color,
                         colorPalettes.keySet());
            System.exit(1);
        }

        // :::  create the output directory if it does not exist
        File outputDirectory = new File(MONOCHROME_ROOT_DIR, conky);
        outputDirectory.mkdirs();

        if (! outputDirectory.exists()) {
            logger.error("unable to create the output directory '{}'", outputDirectory.getPath());
            System.exit(1);
        }

        deleteConkyConfigs(outputDirectory);

        // :::  freemarker setup
        // configure freemarker engine
        Configuration cfg = createFreemarkerConfiguration();
        // add user defined directives
        root.put("outputFileDirective", new OutputFileDirective(outputDirectory));

        // ::: merge freemarker templates and the data model to create the conky configuration files
        logger.info("processing template files:");

        for (String templateFile : new File(TEMPLATE_ROOT_DIR, conky).list((d, f) -> f.endsWith(".ftl"))) {
            logger.info("> {}", templateFile);
            Template template = cfg.getTemplate(conky + "/" + templateFile);
            int dotPosition = templateFile.lastIndexOf('.');
            Writer out = new FileWriter(new File(outputDirectory, templateFile.substring(0, dotPosition)));
            template.process(root, out);
            out.close();
        }

        deleteEmptyConfigs(outputDirectory);
    }

    /**
     * Prints to standard output a table containing the available conky collections and their color scheme options
     */
    private static void listConkyCollections() {
        System.out.println(String.format("%-12s | %s", "collection", "color schemes"));
        System.out.println("-".repeat(12) + " | " + "-".repeat(13));
        File[] collections = TEMPLATE_ROOT_DIR.listFiles((f) -> f.isDirectory() && ! f.getName().contentEquals("lib"));
        Arrays.sort(collections);

        for (File f : collections ) {
            String conky = f.getName();
            File conkyTemplateDir = new File(TEMPLATE_ROOT_DIR, conky);
            File colorConfig = new File(conkyTemplateDir, COLOR_PALETTE_FILENAME);
            Map<String, Object> colorPalettes = loadYamlConfig(colorConfig);
            String colors = colorPalettes.keySet().toString();
            System.out.println(String.format("%-12s | %s", conky, colors.substring(1, colors.length() - 1)));
        }
    }

    /**
     * Loads the contents of the yaml configuration file into memory.<br>
     * Configuration files are deemed critical, any i/o error will cause the program to exit.
     * @param yamlFile yaml configuration file to read
     * @return the configuration as a <code>Map</code> of <code>String | Object</code> pairs.
     */
    private static Map<String, Object> loadYamlConfig(File yamlFile) {
        Map<String, Object> config = null;

        try (InputStream colorPaletteStream = new FileInputStream(yamlFile)) {
            config = yaml.load(colorPaletteStream);
        } catch (FileNotFoundException e) {
            logger.error("configuration file '{}' is missing", yamlFile.getName());
            System.exit(1);
        } catch (IOException e) {
            logger.error("i/o error while reading the yaml file '{}'", yamlFile.getName(), e);
            System.exit(1);
        }

        return config;
    }
    /**
     * Deletes any conky configurations that are just an empty file
     *
     * @param directory folder with conky configurations
     */
    private static void deleteEmptyConfigs(File directory) {
        // edge case to account for templates using a directive that causes an empty config to be created,
        // ex. widgets disk conky
        for(File f : directory.listFiles((d, f) -> ! f.contains("."))) {
            if (f.length() == 0) {
                logger.warn("deleting the generated empty conky config: {}", f.getName());
                f.delete();
            }
        }
    }

    /**
     * Deletes conky configurations from the given directory
     *
     * @param directory folder with conky configurations
     */
    private static void deleteConkyConfigs(File directory) {
        // configuration file names are expected to not have any dots '.' in them.  File names with dots are reserved
        // for settings files such as layout.desktop.cfg or settings.cfg
        for(File f : directory.listFiles((d, f) -> ! f.contains("."))) {
            f.delete();
        }
    }

    /**
     * Parse the command line arguments into an arguments namespace for the application to query.<br>
     * If incorrect arguments are provided, the program's usage message is printed and the program will exit on error.
     * @param args command line arguments as a <code>String</code> array
     * @return a <code>Namespace</code> object
     */
    private static Namespace processArguments(String[] args) {
        String description =
                "generates configuration files for a conky collection based on freemarker templates\n" +
                "the config files are written to the collection's folder in the conky monochrome directory " +
                "(" + MONOCHROME_ROOT_DIR + ")";
        ArgumentParser parser = ArgumentParsers.newFor("ConkyTemplate").build().description(description);
        String usage =
                "${prog} [-h] --list\n" +
                " ".repeat(7) + "${prog} --conky CONKY --color COLOR [--nonverbose] [--device {DESKTOP,LAPTOP}]";
        parser.usage(usage);
        MutuallyExclusiveGroup listOrGenerate = parser.addMutuallyExclusiveGroup().required(true);
        listOrGenerate.addArgument("--list")
                      .action(Arguments.storeTrue()).setDefault(false)
                      .help("list the available conky themes");
        listOrGenerate.addArgument("--conky").help("conky theme to generate configurations for");
        parser.addArgument("--color").help("color scheme to apply to the config");
        ArgumentGroup optionalParameters = parser.addArgumentGroup("optional conky build settings (not all themes support them)");
        optionalParameters.addArgument("--nonverbose")
                          .action(Arguments.storeTrue()).setDefault(false)
                          .help("create a minimalistic version of the conky");
        optionalParameters.addArgument("--device")
                          .type(Arguments.caseInsensitiveEnumType(Device.class))
                          .setDefault(Device.DESKTOP)
                          .help("target device to create conky for, default is DESKTOP");
        String examples = "some examples:\n\n" +
                          "list all available conky themes\n\n" +
                          "\tjava -jar configuration-generator-*.jar --list\n\n" +
                          "generate the blocks conky theme with the green color scheme\n\n" +
                          "\tjava -jar configuration-generator-*.jar --conky blocks --color green";
        parser.epilog(examples);

        return parser.parseArgsOrFail(args);
    }

    private static void validateArguments(String conky) {
        ParameterValidator validator = new ParameterValidator(TEMPLATE_ROOT_DIR.getAbsolutePath());

        if (!validator.isTemplateFolderAvailable(conky)) {
            System.exit(1);
        }
    }

    private static Configuration createFreemarkerConfiguration() throws IOException {
        // Create your configuration instance and specify if up to what FreeMarker version (here 2.3.29) do you want
        // to apply the fixes that are not 100% backward-compatible. See the Configuration JavaDoc for details.
        Configuration cfg = new Configuration(Configuration.VERSION_2_3_29);

        // Specify the source where the template files come from. Here I set a plain directory for it,
        // but non-file-system sources are possible too:
        cfg.setDirectoryForTemplateLoading(TEMPLATE_ROOT_DIR);

        // From here we will set the settings recommended for new projects.
        // These aren't the defaults for backward compatibility.

        // Set the preferred charset template files are stored in. UTF-8 is a good choice in most applications.
        cfg.setDefaultEncoding("UTF-8");
        // change interpolation syntax from ${x} to [=x], this is because conky uses ${...} for its variables
        cfg.setInterpolationSyntax(Configuration.SQUARE_BRACKET_INTERPOLATION_SYNTAX);
        // Sets how errors will appear.
        // During web page *development* TemplateExceptionHandler.HTML_DEBUG_HANDLER is better.
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
        // Don't log exceptions inside FreeMarker that it will throw at you anyway:
        cfg.setLogTemplateExceptions(false);
        // Wrap unchecked exceptions thrown during template processing into TemplateException-s:
        cfg.setWrapUncheckedExceptions(true);
        // Do not fall back to higher scopes when reading a null loop variable:
        cfg.setFallbackOnNullLoopVariable(false);

        return cfg;
    }
}
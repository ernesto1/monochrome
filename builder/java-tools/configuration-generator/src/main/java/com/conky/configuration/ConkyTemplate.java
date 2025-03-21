package com.conky.configuration;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateExceptionHandler;
import net.sourceforge.argparse4j.ArgumentParsers;
import net.sourceforge.argparse4j.impl.Arguments;
import net.sourceforge.argparse4j.inf.ArgumentParser;
import net.sourceforge.argparse4j.inf.MutuallyExclusiveGroup;
import net.sourceforge.argparse4j.inf.Namespace;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.yaml.snakeyaml.Yaml;

import java.io.*;
import java.util.Map;

public class ConkyTemplate {
    private static final Logger logger = LoggerFactory.getLogger(ConkyTemplate.class);
    private static final File MONOCHROME_ROOT_DIR = new File(java.lang.System.getProperty("user.home"), "conky/monochrome");
    /**
     * Root directory with the configuration files for all themes
     */
    private static final File TEMPLATE_ROOT_DIR = new File(MONOCHROME_ROOT_DIR, "builder/freemarker");

    /**
     * Parses the conky freemarker template files based on the given user inputs
     * @param args arguments to the java application
     * @throws IOException if an input file is not available
     * @throws TemplateException if a freemarker error occurs while processing the templates
     */
    public static void main(String[] args) throws IOException, TemplateException {
        Namespace namespace = processArguments(args);
        String conky = namespace.getString("conky");
        validateArguments(conky);

        // ::: create the freemarker data model
        // load hardware data model
        String device = namespace.get("device").toString().toLowerCase();

        InputStream globalSettingsStream = new FileInputStream(new File(TEMPLATE_ROOT_DIR, "hardware-" + device + ".yml"));
        Yaml yaml = new Yaml();
        Map<String, Object> root = yaml.load(globalSettingsStream);
        root.put("conky", conky);               // conky theme being configured
        root.put("device", device);
        boolean isVerbose = ! namespace.getBoolean("nonverbose");
        root.put("isVerbose", isVerbose);

        // load conky theme data model
        File conkyTemplateDir = new File(TEMPLATE_ROOT_DIR, conky);
        InputStream colorPaletteStream = new FileInputStream(new File(conkyTemplateDir, "colorPalette.yml"));
        Map<String, Object> colorPalettes = yaml.load(colorPaletteStream);

        // print available colors if the option was requested by the user and exit
        if (namespace.getBoolean("colors")) {
            logger.info("available color schemes: {}", colorPalettes.keySet());
            System.exit(0);
        }

        logger.info("generating configuration files out of the freemarker templates");
        String setting = String.format("%12s: {}", "conky");
        logger.info(setting, conky);
        setting = String.format("%12s: {}", "device");
        logger.info(setting, device);
        setting = String.format("%12s: {}", "isVerbose");
        logger.info(setting, isVerbose);

        // select desired color
        String color = namespace.getString("color");
        setting = String.format("%12s: {}", "color scheme");
        logger.info(setting, color);

        if (colorPalettes.containsKey(color)) {
            root.putAll((Map<String, Object>) colorPalettes.get(color));
            logger.debug("global + theme data model: {}", root);
        } else {
            logger.error("the '{}' color scheme is not configured for this conky, available colors are: {}",
                         color,
                         colorPalettes.keySet());
            System.exit(1);
        }

        // :::  create the output directory
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
        logger.info("processing template files:");

        // ::: merge freemarker templates and the data model to create the conky configuration files
        for (String templateFile : conkyTemplateDir.list((d, f) -> f.endsWith(".ftl"))) {
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
     * Parse the command line arguments into an arguments namespace for the application to query
     * @param args command line arguments as a <code>String</code> array
     * @return a <code>Namespace</code> object
     */
    private static Namespace processArguments(String[] args) {
        StringBuilder sb = new StringBuilder();
        sb.append("generates conky configuration files based on freemarker templates.\n")
          .append("the config files are written to the conky monochrome directory (").append(MONOCHROME_ROOT_DIR).append(") ")
          .append("under their corresponding conky collection folder.");
        ArgumentParser parser = ArgumentParsers.newFor("ConkyTemplate").build()
                                               .description(sb.toString());
        parser.addArgument("--conky").required(true).help("conky theme to create the configuration for");
        MutuallyExclusiveGroup colorParameters = parser.addMutuallyExclusiveGroup();
        colorParameters.addArgument("--color").help("color scheme to apply to the config");
        colorParameters.addArgument("--colors").action(Arguments.storeTrue()).setDefault(false)
                       .help("list available color schemes for the chosen conky theme");
        parser.addArgument("--nonverbose").action(Arguments.storeTrue()).setDefault(false)
              .help("create a minimal version of the conky (if the theme supports it)");
        parser.addArgument("--device").type(Arguments.caseInsensitiveEnumType(Device.class))
                                                   .setDefault(Device.DESKTOP)
                                                   .help("target device (if the theme supports it)");

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

package com.conky.configuration;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateExceptionHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.yaml.snakeyaml.Yaml;

import java.io.*;
import java.util.Map;

public class ConkyTemplate {
    private static final Logger logger = LoggerFactory.getLogger(ConkyTemplate.class);
    private static final File MONOCHROME_ROOT_DIR = new File(System.getProperty("user.home"), "conky/monochrome");
    /**
     * Root directory with the configuration files for all themes
     */
    private static final File TEMPLATE_ROOT_DIR = new File(MONOCHROME_ROOT_DIR, "builder/freemarker");
    private static final String OUTPUT_DIR = "/tmp/monochrome";

    /**
     * Parses the conky freemarker template file based on the given configuration
     * @param args <tt>conkyTheme</tt> <tt>color</tt> <tt>device</tt>
     * @throws IOException if an input file is not available
     * @throws TemplateException if a freemarker error occurs while processing the templates
     */
    public static void main(String[] args) throws IOException, TemplateException {
        // 1. validate user input
        validateArguments(args);

        // 2. freemarker data model creation
        // load global data model
        InputStream globalSettingsStream = new FileInputStream(new File(TEMPLATE_ROOT_DIR, "hardware.yml"));
        Yaml yaml = new Yaml();
        Map<String, Object> root = yaml.load(globalSettingsStream);
        root.put("conky", args[0]);                 // conky theme being configured
        root.put("system", args[2].toLowerCase());  // desktop or laptop
        // load conky theme data model
        String conky = args[0];
        File conkyTemplateDir = new File(TEMPLATE_ROOT_DIR, conky);
        InputStream colorPaletteStream = new FileInputStream(new File(conkyTemplateDir, "colorPalette.yml"));
        Map<String, Object> themes = yaml.load(colorPaletteStream);
        // select desired color
        String color = args[1];

        if (themes.containsKey(color)) {
            logger.info("applying the '{}' color scheme", color);
            root.putAll((Map<String, Object>) themes.get(color));
            logger.debug("global + theme data model: {}", root);
        } else {
            logger.error("color scheme '{}' is not configured for this conky, available colors are: {}", color, themes.keySet());
            System.exit(1);
        }

        // 3. freemarker setup
        // add user defined directives
        root.put("outputFileDirective", new OutputFileDirective(OUTPUT_DIR));
        // create the output directory
        File outputDirectory = new File(OUTPUT_DIR);
        outputDirectory.mkdirs();   // will not throw an exception if the directory already exists

        if (!outputDirectory.exists()) {
            logger.error("unable to create the output directory '{}'", OUTPUT_DIR);
            System.exit(1);
        }

        // configure freemarker engine
        Configuration cfg = createFreemarkerConfiguration(TEMPLATE_ROOT_DIR);
        logger.info("processing template files:");

        // 4. merge freemarker templates and the data model to create the output files
        for (String templateFile : conkyTemplateDir.list((d, f) -> f.endsWith(".ftl"))) {
            logger.info("> {}", templateFile);
            Template template = cfg.getTemplate(conky + "/" + templateFile);
            int dotPosition = templateFile.lastIndexOf('.');
            Writer out = new FileWriter(new File(outputDirectory, templateFile.substring(0, dotPosition)));
            template.process(root, out);
            out.close();
        }
    }

    /**
     * Ensures the required arguments were provided and that they are proper, ie.
     * <ul>
     *     <li>the conky theme must exist, ie. a template directory under its name exists</li>
     *     <li>system is either <tt>desktop</tt> or <tt>laptop</tt></li>
     * </ul>
     * If a validation fails the method will <b>exit</b> the program with an error status code.
     *
     * @param args command line arguments provided to the program
     */
    private static void validateArguments(String[] args) {
        if (args.length !=3) {
            logger.error("usage: conkyTemplate <conky theme> <color> <device>");
            logger.error("where device can be 'desktop' or 'laptop'");
            System.exit(1);
        }

        // verify conky theme directory exists
        String conkyTheme = args[0];
        File conkyDir = new File(MONOCHROME_ROOT_DIR, conkyTheme);

        if (conkyDir.isDirectory()) {
            logger.info("creating configuration files for the '{}' conky", conkyTheme);
        } else {
            logger.error("'{}' conky does not exist under the monochrome conky suite", conkyTheme);
            System.exit(1);
        }

        // 'system' argument must be a valid value
        try {
            Device.valueOf(args[2].toUpperCase());
        } catch(IllegalArgumentException e) {
            logger.error("'{}' is not a supported device, accepted values are: {}", args[2], Device.values());
            System.exit(1);
        }
    }

    private static Configuration createFreemarkerConfiguration(File templateDirectory) throws IOException {
        // Create your Configuration instance, and specify if up to what FreeMarker
        // version (here 2.3.29) do you want to apply the fixes that are not 100%
        // backward-compatible. See the Configuration JavaDoc for details.
        Configuration cfg = new Configuration(Configuration.VERSION_2_3_29);

        // Specify the source where the template files come from. Here I set a
        // plain directory for it, but non-file-system sources are possible too:
        cfg.setDirectoryForTemplateLoading(templateDirectory);

        // From here we will set the settings recommended for new projects. These
        // aren't the defaults for backward compatibilty.

        // Set the preferred charset template files are stored in. UTF-8 is
        // a good choice in most applications:
        cfg.setDefaultEncoding("UTF-8");

        // change interpolation syntax from ${x} to [=x]
        // this is because conky uses ${..} for its variables
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

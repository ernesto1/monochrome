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
     * @param args arguments to the java application
     * @throws IOException if an input file is not available
     * @throws TemplateException if a freemarker error occurs while processing the templates
     */
    public static void main(String[] args) throws IOException, TemplateException {
        // 1. validate user input
        ParameterValidator validator = new ParameterValidator(TEMPLATE_ROOT_DIR.getAbsolutePath());

        if (!validator.isUserInputProper(args)) {
            System.exit(1);
        }

        String conky = args[0];
        logger.info("creating configuration files for the '{}' conky", conky);
        // 2. create the freemarker data model
        // load hardware data model
        String system = args[2].toLowerCase();     // desktop or laptop
        InputStream globalSettingsStream = new FileInputStream(new File(TEMPLATE_ROOT_DIR, "hardware-" + system + ".yml"));
        Yaml yaml = new Yaml();
        Map<String, Object> root = yaml.load(globalSettingsStream);
        root.put("conky", conky);               // conky theme being configured
        root.put("system", system);
        root.put("isElaborate", true);       // default is elaborate conky

        if (args.length > 3) {
            root.put("isElaborate", Boolean.valueOf(args[3]));
        }

        // load conky theme data model
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
            logger.error("'{}' color scheme is not configured for this conky, available colors are: {}", color, themes.keySet());
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

    private static Configuration createFreemarkerConfiguration(File templateDirectory) throws IOException {
        // Create your configuration instance and specify if up to what FreeMarker version (here 2.3.29) do you want
        // to apply the fixes that are not 100% backward-compatible. See the Configuration JavaDoc for details.
        Configuration cfg = new Configuration(Configuration.VERSION_2_3_29);

        // Specify the source where the template files come from. Here I set a plain directory for it,
        // but non-file-system sources are possible too:
        cfg.setDirectoryForTemplateLoading(templateDirectory);

        // From here we will set the settings recommended for new projects.
        // These aren't the defaults for backward compatibility.

        // Set the preferred charset template files are stored in. UTF-8 is a good choice in most applications.
        cfg.setDefaultEncoding("UTF-8");
        // change interpolation syntax from ${x} to [=x], this is because conky uses ${..} for its variables
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

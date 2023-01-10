package com.conky;

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
    private static final String CONKY_DIR = "/home/ernesto/conky/monochrome";
    /**
     * Root directory with the configuration files for all themes
     */
    private static final String CONKY_BUILD_DIR = CONKY_DIR + "/builder";
    private static final String OUTPUT_DIR = "/tmp/monochrome/target";

    /**
     * Parses the conky freemarker template file based on the given configuration
     * @param args
     * @throws IOException if the input files are not available
     * @throws TemplateException if a freemarker error occurs while processing the templates
     */
    public static void main(String[] args) throws IOException, TemplateException {
        validateArguments(args);

        // load global data model
        File buildDirectory = new File(CONKY_BUILD_DIR);
        InputStream globalSettingsStream = new FileInputStream(new File(buildDirectory, "globalSettings.yml"));
        Yaml yaml = new Yaml();
        Map<String, Object> root = yaml.load(globalSettingsStream);
        // set up system variable
        root.put("system", args[2]);
        // load conky theme data model
        File templateDirectory = new File(buildDirectory, args[0]);
        InputStream colorPaletteStream = new FileInputStream(new File(templateDirectory, "colorPalette.yml"));
        Map<String, Object> themes = yaml.load(colorPaletteStream);
        // select desired color
        String color = args[1];

        if (themes.containsKey(color)) {
            logger.info("using {} color scheme", color);
            root.putAll((Map<String, Object>) themes.get(color));
            logger.debug("global + theme data model: {}", root);
        } else {
            logger.error("color scheme '{}' is not configured for this conky, available colors are {}", color, themes.keySet());
            System.exit(1);
        }

        Configuration cfg = createFreemarkerConfiguration(templateDirectory);
        File outputDirectory = new File(OUTPUT_DIR);

        if (!outputDirectory.exists()) {
            // turns out the create directory operation "fails" if the directory already exists
            boolean isDirectoryCreated = outputDirectory.mkdirs();

            if (!isDirectoryCreated) {
                logger.error("unable to create the output directory {}", OUTPUT_DIR);
                System.exit(1);
            }
        }

        logger.info("processing template files:");
        // merging templates and the data model
        for (File templateFile : templateDirectory.listFiles((d, f) -> f.endsWith(".ftl"))) {
            logger.info("> {}", templateFile.getName());
            Template template = cfg.getTemplate(templateFile.getName());
            int dotPosition = templateFile.getName().lastIndexOf('.');
            Writer out = new FileWriter(new File(outputDirectory, templateFile.getName().substring(0, dotPosition)));
            template.process(root, out);
            out.close();
        }
    }

    /**
     * Ensures required arguments were provided and that they are proper
     * @param args arguments provided to the program
     */
    private static void validateArguments(String[] args) {
        if (args.length !=3) {
            System.err.println("usage: conkyTemplate <conky theme> <color> <system>");
            System.err.println("where system can be 'desktop' or 'laptop'");
            System.exit(1);
        }

        // verify conky theme directory exists
        File conkyDir = new File(CONKY_DIR, args[0]);

        if (conkyDir.isDirectory()) {
            logger.info("creating configuration files for the {} conky", args[0]);
        } else {
            logger.error("conky directory {} does not exist", conkyDir);
            System.exit(1);
        }

        // TODO ensure proper system variable was provided
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

        // Don't log exceptions inside FreeMarker that it will thrown at you anyway:
        cfg.setLogTemplateExceptions(false);

        // Wrap unchecked exceptions thrown during template processing into TemplateException-s:
        cfg.setWrapUncheckedExceptions(true);

        // Do not fall back to higher scopes when reading a null loop variable:
        cfg.setFallbackOnNullLoopVariable(false);
        return cfg;
    }
}

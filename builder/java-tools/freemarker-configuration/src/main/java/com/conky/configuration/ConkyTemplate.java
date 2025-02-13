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
    private static final String OUTPUT_DIR = "/tmp/monochrome";

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
        String system = namespace.get("system").toString().toLowerCase();
        InputStream globalSettingsStream = new FileInputStream(new File(TEMPLATE_ROOT_DIR, "hardware-" + system + ".yml"));
        Yaml yaml = new Yaml();
        Map<String, Object> root = yaml.load(globalSettingsStream);
        root.put("conky", conky);               // conky theme being configured
        root.put("system", system);
        root.put("isVerbose", ! namespace.getBoolean("nonverbose"));

        // load conky theme data model
        File conkyTemplateDir = new File(TEMPLATE_ROOT_DIR, conky);
        InputStream colorPaletteStream = new FileInputStream(new File(conkyTemplateDir, "colorPalette.yml"));
        Map<String, Object> colorPalettes = yaml.load(colorPaletteStream);

        // print available colors if the option was requested by the user and exit
        if (namespace.getBoolean("colors")) {
            logger.info("available color schemes: {}", colorPalettes.keySet());
            java.lang.System.exit(0);
        }

        // select desired color
        logger.info("creating configuration files for the '{}' conky", conky);
        String color = namespace.getString("color");

        if (colorPalettes.containsKey(color)) {
            logger.info("applying the '{}' color scheme", color);
            root.putAll((Map<String, Object>) colorPalettes.get(color));
            logger.debug("global + theme data model: {}", root);
        } else {
            logger.error("'{}' color scheme is not configured for this conky, available colors are: {}", color, colorPalettes.keySet());
            java.lang.System.exit(1);
        }

        // :::  create the output directory
        File outputDirectory = new File(OUTPUT_DIR);
        outputDirectory.mkdirs();   // will not throw an exception if the directory already exists

        if (!outputDirectory.exists()) {
            logger.error("unable to create the output directory '{}'", OUTPUT_DIR);
            java.lang.System.exit(1);
        }

        emptyDirectory(outputDirectory);

        // :::  freemarker setup
        // configure freemarker engine
        Configuration cfg = createFreemarkerConfiguration(TEMPLATE_ROOT_DIR);
        // add user defined directives
        root.put("outputFileDirective", new OutputFileDirective(OUTPUT_DIR));
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
    }

    private static void emptyDirectory(File outputDirectory) {
        for(File f : outputDirectory.listFiles()) {
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
        sb.append("creates conky configuration files based on freemarker templates\n")
          .append("config files will be written to the ").append(OUTPUT_DIR).append(" directory");
        ArgumentParser parser = ArgumentParsers.newFor("ConkyTemplate").build()
                                               .description(sb.toString());
        parser.addArgument("--conky").required(true).help("conky theme to create the configuration for");
        MutuallyExclusiveGroup colorParameters = parser.addMutuallyExclusiveGroup();
        colorParameters.addArgument("--color").help("color scheme to apply to the config");
        colorParameters.addArgument("--colors").action(Arguments.storeTrue()).setDefault(false)
                       .help("list available color schemes for the chosen conky theme");
        parser.addArgument("--nonverbose").action(Arguments.storeTrue()).setDefault(false)
              .help("create a minimal version of the conky (if the theme supports it)");
        parser.addArgument("--system").type(Arguments.caseInsensitiveEnumType(System.class))
                                                   .setDefault(System.DESKTOP)
                                                   .help("target system (if available)");
        Namespace namespace = parser.parseArgsOrFail(args);

        return namespace;
    }

    private static void validateArguments(String conky) {
        ParameterValidator validator = new ParameterValidator(TEMPLATE_ROOT_DIR.getAbsolutePath());

        if (!validator.isTemplateFolderAvailable(conky)) {
            java.lang.System.exit(1);
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

package com.conky.configuration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.*;
import java.util.function.Predicate;

/**
 * Ensures the command line arguments provided by the user are proper
 */
public class ParameterValidator {
    private static final Logger logger = LoggerFactory.getLogger(ParameterValidator.class);
    private final String freemarkerRootDir;
    private List<Predicate<String[]>> validators;

    public ParameterValidator(String directory) {
        freemarkerRootDir = directory;
        validators = new ArrayList<>();
        validators.add(this::isCorrectNumberOfArguments);
        validators.add(this::isTemplateFolderAvailable);
        validators.add(this::isSystemSupported);
    }

    public boolean isUserInputProper(String[] args) {
        return validators.stream().allMatch(p -> p.test(args));
    }
    private boolean isCorrectNumberOfArguments(String[] args) {
        if (args.length !=3) {
            logger.error("usage: conkyTemplate <conky theme> <color> <device>");
            logger.error("where device can be 'desktop' or 'laptop'");
            return false;
        }

        return true;
    }

    private boolean isTemplateFolderAvailable(String[] args) {
        String conkyTheme = args[0];
        File conkyDir = new File(freemarkerRootDir, conkyTheme);

        if (conkyDir.isDirectory()) {
            return true;
        } else {
            logger.error("'{}' is not a template directory in the freemarker root folder", conkyTheme);
            return false;
        }
    }

    private boolean isSystemSupported(String[] args) {
        try {
            Device.valueOf(args[2].toUpperCase());
        } catch(IllegalArgumentException e) {
            logger.error("'{}' is not a supported device, accepted values are: {}", args[2], Device.values());
            return false;
        }

        return true;
    }
}

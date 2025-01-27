package com.conky.configuration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;

/**
 * Ensures the command line arguments provided by the user are proper
 */
public class ParameterValidator {
    private static final Logger logger = LoggerFactory.getLogger(ParameterValidator.class);
    private final String freemarkerRootDir;

    public ParameterValidator(String directory) {
        freemarkerRootDir = directory;
    }

    public boolean isTemplateFolderAvailable(String conkyTheme) {
        File conkyDir = new File(freemarkerRootDir, conkyTheme);

        if (conkyDir.isDirectory()) {
            return true;
        } else {
            logger.error("'{}' is not a template directory in the freemarker root folder", conkyTheme);
            return false;
        }
    }
}

package com.conky.configuration;

import freemarker.core.Environment;
import freemarker.template.*;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Map;

/**
 * User defined directive to create multiple files out of a single template
 */
public class OutputFileDirective implements TemplateDirectiveModel {
    File outputDirectory;

    /**
     * Creates a new instance of the directive
     * @param outputDirectory path to the output directory where all configuration files are being written by this process
     */
    public OutputFileDirective(File outputDirectory) {
        this.outputDirectory = outputDirectory;
    }

    @Override
    public void execute(Environment environment,
                        Map parameters,
                        TemplateModel[] templateModels,
                        TemplateDirectiveBody body) throws TemplateException, IOException {
        SimpleScalar filename = (SimpleScalar) parameters.get("filename");
        FileWriter fileWriter = new FileWriter(new File(outputDirectory, filename.getAsString()));
        body.render(fileWriter);
        fileWriter.close();
    }
}

package com.example.lex.config;

import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertiesPropertySource;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

public class DotEnvPropertySource implements ApplicationContextInitializer<ConfigurableApplicationContext> {

    @Override
    public void initialize(ConfigurableApplicationContext applicationContext) {
        ConfigurableEnvironment environment = applicationContext.getEnvironment();
        
        // Try to load .env file from project root
        Path envPath = Paths.get(".env");
        
        if (Files.exists(envPath)) {
            try {
                Properties props = new Properties();
                
                // Read .env file
                Files.lines(envPath)
                    .filter(line -> !line.trim().isEmpty())
                    .filter(line -> !line.trim().startsWith("#"))
                    .forEach(line -> {
                        int separatorIndex = line.indexOf('=');
                        if (separatorIndex > 0) {
                            String key = line.substring(0, separatorIndex).trim();
                            String value = line.substring(separatorIndex + 1).trim();
                            
                            // Remove quotes if present
                            if (value.startsWith("\"") && value.endsWith("\"")) {
                                value = value.substring(1, value.length() - 1);
                            } else if (value.startsWith("'") && value.endsWith("'")) {
                                value = value.substring(1, value.length() - 1);
                            }
                            
                            props.setProperty(key, value);
                            
                            // Also set as system property for ${} resolution
                            System.setProperty(key, value);
                        }
                    });
                
                environment.getPropertySources().addFirst(
                    new PropertiesPropertySource("dotenv", props)
                );
                
                System.out.println("✓ Loaded environment variables from .env file");
                
            } catch (IOException e) {
                System.err.println("Warning: Could not load .env file: " + e.getMessage());
            }
        } else {
            System.out.println("No .env file found. Using system environment variables.");
        }
    }
}
#!/bin/bash

# Amazon Lex Spring Boot Project Setup Script
# This script creates the complete folder structure for the project

echo "Creating Amazon Lex Spring Boot project structure..."

# Create main directory structure
mkdir -p src/main/java/com/example/lex/{config,controller,service,dto,exception}
mkdir -p src/main/resources
mkdir -p src/test/java/com/example/lex

echo "✓ Created folder structure"

# Create pom.xml
cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>lex-integration</artifactId>
    <version>1.0.0</version>
    <name>Amazon Lex Spring Boot Integration</name>

    <properties>
        <java.version>17</java.version>
        <aws.sdk.version>2.21.0</aws.sdk.version>
    </properties>

    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- AWS SDK for Lex V2 -->
        <dependency>
            <groupId>software.amazon.awssdk</groupId>
            <artifactId>lexruntimev2</artifactId>
            <version>${aws.sdk.version}</version>
        </dependency>

        <!-- AWS SDK Core -->
        <dependency>
            <groupId>software.amazon.awssdk</groupId>
            <artifactId>core</artifactId>
            <version>${aws.sdk.version}</version>
        </dependency>

        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

echo "✓ Created pom.xml"

# Create application.properties
cat > src/main/resources/application.properties << 'EOF'
# AWS Configuration
aws.access.key.id=YOUR_ACCESS_KEY_ID
aws.secret.access.key=YOUR_SECRET_ACCESS_KEY
aws.region=us-east-1

# Amazon Lex Configuration
aws.lex.bot.id=YOUR_BOT_ID
aws.lex.bot.alias.id=YOUR_BOT_ALIAS_ID
aws.lex.locale.id=en_US

# Server Configuration
server.port=8080

# Logging
logging.level.root=INFO
logging.level.com.example.lex=DEBUG
logging.level.software.amazon.awssdk=WARN
EOF

echo "✓ Created application.properties"

# Create Main Application Class
cat > src/main/java/com/example/lex/LexIntegrationApplication.java << 'EOF'
package com.example.lex;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class LexIntegrationApplication {

    public static void main(String[] args) {
        SpringApplication.run(LexIntegrationApplication.class, args);
    }
}
EOF

echo "✓ Created LexIntegrationApplication.java"

# Create AWS Config
cat > src/main/java/com/example/lex/config/AwsLexConfig.java << 'EOF'
package com.example.lex.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.lexruntimev2.LexRuntimeV2Client;

@Configuration
public class AwsLexConfig {

    @Value("${aws.access.key.id}")
    private String accessKeyId;

    @Value("${aws.secret.access.key}")
    private String secretAccessKey;

    @Value("${aws.region}")
    private String region;

    @Bean
    public LexRuntimeV2Client lexRuntimeV2Client() {
        AwsBasicCredentials credentials = AwsBasicCredentials.create(
            accessKeyId,
            secretAccessKey
        );

        return LexRuntimeV2Client.builder()
            .region(Region.of(region))
            .credentialsProvider(StaticCredentialsProvider.create(credentials))
            .build();
    }
}
EOF

echo "✓ Created AwsLexConfig.java"

# Create DTOs
cat > src/main/java/com/example/lex/dto/LexRequest.java << 'EOF'
package com.example.lex.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LexRequest {
    
    @NotBlank(message = "Message cannot be empty")
    private String message;
    
    @NotBlank(message = "Session ID cannot be empty")
    private String sessionId;
    
    private String userId;
}
EOF

echo "✓ Created LexRequest.java"

cat > src/main/java/com/example/lex/dto/LexResponse.java << 'EOF'
package com.example.lex.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LexResponse {
    
    private String sessionId;
    private List<String> messages;
    private String sessionState;
    private String intent;
    private Map<String, String> slots;
    private String interpretationSource;
}
EOF

echo "✓ Created LexResponse.java"

# Create Service
cat > src/main/java/com/example/lex/service/LexService.java << 'EOF'
package com.example.lex.service;

import com.example.lex.dto.LexRequest;
import com.example.lex.dto.LexResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.lexruntimev2.LexRuntimeV2Client;
import software.amazon.awssdk.services.lexruntimev2.model.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Slf4j
public class LexService {

    private final LexRuntimeV2Client lexClient;

    @Value("${aws.lex.bot.id}")
    private String botId;

    @Value("${aws.lex.bot.alias.id}")
    private String botAliasId;

    @Value("${aws.lex.locale.id}")
    private String localeId;

    public LexService(LexRuntimeV2Client lexClient) {
        this.lexClient = lexClient;
    }

    public LexResponse sendMessage(LexRequest request) {
        try {
            log.debug("Sending message to Lex: {}", request.getMessage());
            
            RecognizeTextRequest recognizeTextRequest = RecognizeTextRequest.builder()
                .botId(botId)
                .botAliasId(botAliasId)
                .localeId(localeId)
                .sessionId(request.getSessionId())
                .text(request.getMessage())
                .build();

            RecognizeTextResponse response = lexClient.recognizeText(recognizeTextRequest);
            
            log.debug("Received response from Lex");

            List<String> messages = response.messages().stream()
                .map(Message::content)
                .collect(Collectors.toList());

            Map<String, String> slots = new HashMap<>();
            if (response.sessionState() != null && response.sessionState().intent() != null) {
                Map<String, Slot> lexSlots = response.sessionState().intent().slots();
                if (lexSlots != null) {
                    lexSlots.forEach((key, value) -> {
                        if (value != null && value.value() != null) {
                            slots.put(key, value.value().interpretedValue());
                        }
                    });
                }
            }

            return LexResponse.builder()
                .sessionId(request.getSessionId())
                .messages(messages)
                .sessionState(response.sessionState() != null ? 
                    response.sessionState().intentAsString() : null)
                .intent(response.sessionState() != null && 
                    response.sessionState().intent() != null ?
                    response.sessionState().intent().name() : null)
                .slots(slots)
                .interpretationSource(response.interpretationsAsStrings().toString())
                .build();

        } catch (LexRuntimeV2Exception e) {
            log.error("Error calling Amazon Lex: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to communicate with Lex bot", e);
        }
    }

    public void deleteSession(String sessionId) {
        try {
            DeleteSessionRequest deleteRequest = DeleteSessionRequest.builder()
                .botId(botId)
                .botAliasId(botAliasId)
                .localeId(localeId)
                .sessionId(sessionId)
                .build();

            lexClient.deleteSession(deleteRequest);
            log.info("Session deleted: {}", sessionId);
            
        } catch (LexRuntimeV2Exception e) {
            log.error("Error deleting session: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to delete session", e);
        }
    }

    public Map<String, Object> getSession(String sessionId) {
        try {
            GetSessionRequest getRequest = GetSessionRequest.builder()
                .botId(botId)
                .botAliasId(botAliasId)
                .localeId(localeId)
                .sessionId(sessionId)
                .build();

            GetSessionResponse response = lexClient.getSession(getRequest);
            
            Map<String, Object> sessionInfo = new HashMap<>();
            sessionInfo.put("sessionId", response.sessionId());
            sessionInfo.put("messages", response.messages());
            sessionInfo.put("interpretations", response.interpretations());
            
            return sessionInfo;
            
        } catch (LexRuntimeV2Exception e) {
            log.error("Error getting session: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to get session", e);
        }
    }
}
EOF

echo "✓ Created LexService.java"

# Create Controller
cat > src/main/java/com/example/lex/controller/LexController.java << 'EOF'
package com.example.lex.controller;

import com.example.lex.dto.LexRequest;
import com.example.lex.dto.LexResponse;
import com.example.lex.service.LexService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/lex")
@RequiredArgsConstructor
@Slf4j
public class LexController {

    private final LexService lexService;

    @PostMapping("/send-message")
    public ResponseEntity<LexResponse> sendMessage(@Valid @RequestBody LexRequest request) {
        log.info("Received message request for session: {}", request.getSessionId());
        
        try {
            LexResponse response = lexService.sendMessage(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error processing message", e);
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(LexResponse.builder()
                    .messages(List.of("Error processing your request"))
                    .build());
        }
    }

    @DeleteMapping("/session/{sessionId}")
    public ResponseEntity<String> deleteSession(@PathVariable String sessionId) {
        log.info("Deleting session: {}", sessionId);
        
        try {
            lexService.deleteSession(sessionId);
            return ResponseEntity.ok("Session deleted successfully");
        } catch (Exception e) {
            log.error("Error deleting session", e);
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Error deleting session");
        }
    }

    @GetMapping("/session/{sessionId}")
    public ResponseEntity<Map<String, Object>> getSession(@PathVariable String sessionId) {
        log.info("Getting session info: {}", sessionId);
        
        try {
            Map<String, Object> sessionInfo = lexService.getSession(sessionId);
            return ResponseEntity.ok(sessionInfo);
        } catch (Exception e) {
            log.error("Error getting session", e);
            return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .build();
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Lex integration is running");
    }
}
EOF

echo "✓ Created LexController.java"

# Create Exception Handler
cat > src/main/java/com/example/lex/exception/GlobalExceptionHandler.java << 'EOF'
package com.example.lex.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationExceptions(
            MethodArgumentNotValidException ex) {
        
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errors);
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleRuntimeException(RuntimeException ex) {
        log.error("Runtime exception occurred", ex);
        
        Map<String, String> error = new HashMap<>();
        error.put("error", ex.getMessage());
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleGenericException(Exception ex) {
        log.error("Unexpected exception occurred", ex);
        
        Map<String, String> error = new HashMap<>();
        error.put("error", "An unexpected error occurred");
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}
EOF

echo "✓ Created GlobalExceptionHandler.java"

# Create .gitignore
cat > .gitignore << 'EOF'
# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
.mvn/wrapper/maven-wrapper.jar

# Spring Boot
.springBeans
.sts4-cache

# IntelliJ IDEA
.idea/
*.iws
*.iml
*.ipr
out/

# Eclipse
.classpath
.project
.settings/
bin/

# VS Code
.vscode/

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Application properties with secrets
application-local.properties
application-dev.properties
application-prod.properties
EOF

echo "✓ Created .gitignore"

# Create README
cat > README.md << 'EOF'
# Amazon Lex Spring Boot Integration

Backend application for integrating Amazon Lex chatbot with Spring Boot.

## Prerequisites

- Java 17+
- Maven 3.6+
- AWS Account with Lex Bot configured
- AWS IAM credentials

## Quick Start

1. **Configure AWS credentials** in `src/main/resources/application.properties`
2. **Build the project**: `mvn clean install`
3. **Run the application**: `mvn spring-boot:run`
4. **Test**: Navigate to `http://localhost:8080/api/lex/health`

## API Endpoints

- `POST /api/lex/send-message` - Send message to Lex bot
- `GET /api/lex/session/{sessionId}` - Get session info
- `DELETE /api/lex/session/{sessionId}` - Delete session
- `GET /api/lex/health` - Health check

## Configuration

Update these values in `application.properties`:
- `aws.access.key.id`
- `aws.secret.access.key`
- `aws.lex.bot.id`
- `aws.lex.bot.alias.id`

See setup guide for detailed instructions.
EOF

echo "✓ Created README.md"

echo ""
echo "=========================================="
echo "Project structure created successfully!"
echo "=========================================="
echo ""
echo "Project structure:"
tree -L 4 -I 'target' 2>/dev/null || find . -type d -not -path '*/\.*' | sed 's|[^/]*/|  |g'

echo ""
echo "Next steps:"
echo "1. Update AWS credentials in: src/main/resources/application.properties"
echo "2. Run: mvn clean install"
echo "3. Run: mvn spring-boot:run"
EOF

chmod +x setup.sh

echo "Setup script created successfully!"

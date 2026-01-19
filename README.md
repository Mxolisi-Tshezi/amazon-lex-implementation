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

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
            
            // Build the recognize text request
            RecognizeTextRequest recognizeTextRequest = RecognizeTextRequest.builder()
                .botId(botId)
                .botAliasId(botAliasId)
                .localeId(localeId)
                .sessionId(request.getSessionId())
                .text(request.getMessage())
                .build();

            // Call Lex
            RecognizeTextResponse response = lexClient.recognizeText(recognizeTextRequest);
            
            log.debug("Received response from Lex");

            // Extract messages
            List<String> messages = response.messages().stream()
                .map(Message::content)
                .collect(Collectors.toList());

            // Extract slots
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

            // Build response
            return LexResponse.builder()
                .sessionId(request.getSessionId())
                .messages(messages)
                .sessionState(response.sessionState() != null ? 
                    response.sessionState().intent() != null ? 
                    response.sessionState().intent().state().toString() : "Unknown" : "Unknown")
                .intent(response.sessionState() != null && 
                    response.sessionState().intent() != null ?
                    response.sessionState().intent().name() : null)
                .slots(slots)
                .interpretationSource(response.interpretations() != null ? 
                    response.interpretations().toString() : "")
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
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

import java.util.Collections;  // <-- ADD THIS LINE
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
                    .messages(Collections.singletonList("Error processing your request"))
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
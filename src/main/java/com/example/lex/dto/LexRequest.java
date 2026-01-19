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
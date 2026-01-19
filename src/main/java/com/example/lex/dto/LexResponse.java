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

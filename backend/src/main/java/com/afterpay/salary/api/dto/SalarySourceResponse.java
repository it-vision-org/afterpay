package com.afterpay.salary.api.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record SalarySourceResponse(
    UUID id,
    String name,
    BigDecimal amount,
    Integer payDay,
    Instant createdAt,
    Instant updatedAt
) {
}

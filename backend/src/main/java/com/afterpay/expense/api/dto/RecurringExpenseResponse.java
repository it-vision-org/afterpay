package com.afterpay.expense.api.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

import com.afterpay.expense.domain.Category;

public record RecurringExpenseResponse(
    UUID id,
    String name,
    BigDecimal amount,
    Category category,
    String description,
    boolean active,
    String icon,
    String color,
    Instant createdAt,
    Instant updatedAt
) {
}

package com.afterpay.expense.api.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import com.afterpay.expense.domain.Category;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record ExpenseRequest(
    @NotBlank @Size(max = 200) String name,
    @NotNull @Positive BigDecimal amount,
    @NotNull Category category,
    @NotNull LocalDate expenseDate,
    @Size(max = 500) String note,
    @Size(max = 50) String icon,
    @Size(max = 7) String color
) {
}

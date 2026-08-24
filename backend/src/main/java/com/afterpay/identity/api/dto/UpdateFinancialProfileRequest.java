package com.afterpay.identity.api.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record UpdateFinancialProfileRequest(
    @NotNull @Positive BigDecimal monthlySalary,
    @NotBlank @Size(max = 3) String currency,
    @Min(1) @Max(31) int salaryDay
) {
}

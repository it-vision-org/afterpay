package com.afterpay.salary.api.dto;

import java.math.BigDecimal;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record SalarySourceRequest(
    @NotBlank @Size(max = 200) String name,
    @NotNull @Positive BigDecimal amount,
    @Min(1) @Max(31) Integer payDay
) {
}

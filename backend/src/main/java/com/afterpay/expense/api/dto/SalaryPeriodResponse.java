package com.afterpay.expense.api.dto;

import java.time.LocalDate;

public record SalaryPeriodResponse(
    LocalDate start,
    LocalDate end,
    String label
) {
}

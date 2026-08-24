package com.afterpay.identity.api.dto;

import java.math.BigDecimal;
import java.util.UUID;

import com.afterpay.identity.domain.User;

public record UserSummary(
    UUID id,
    String fullName,
    String email,
    BigDecimal monthlySalary,
    String currency,
    int salaryDay
) {
    public static UserSummary from(User user) {
        return new UserSummary(
            user.getId(),
            user.getFullName(),
            user.getEmail(),
            user.getMonthlySalary(),
            user.getCurrency(),
            user.getSalaryDay()
        );
    }
}

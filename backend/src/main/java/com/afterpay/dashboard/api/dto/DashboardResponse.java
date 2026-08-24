package com.afterpay.dashboard.api.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import com.afterpay.expense.api.dto.ExpenseResponse;

public record DashboardResponse(
    BigDecimal salary,
    BigDecimal recurringExpensesTotal,
    BigDecimal oneTimeExpensesTotal,
    BigDecimal totalSpent,
    BigDecimal remaining,
    BigDecimal percentageUsed,
    boolean overBudget,
    LocalDate salaryPeriodStart,
    LocalDate salaryPeriodEnd,
    List<ExpenseResponse> recentExpenses
) {
}

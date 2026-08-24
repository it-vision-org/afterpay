package com.afterpay.expense.api.dto;

/**
 * Which salary period to scope an expense list query to. Not persisted —
 * purely a request-side filter resolved against {@code SalaryPeriodService}.
 */
public enum ExpensePeriodFilter {
    CURRENT,
    PREVIOUS,
    ALL
}

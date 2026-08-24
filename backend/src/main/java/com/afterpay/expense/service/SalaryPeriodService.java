package com.afterpay.expense.service;

import java.time.Clock;
import java.time.LocalDate;
import java.time.YearMonth;

import org.springframework.stereotype.Service;

/**
 * Single source of truth for "salary period" math: the rolling month that
 * runs from a user's configured salary day to the day before the next
 * occurrence of that day, safely clamped for months shorter than the
 * configured day (e.g. salaryDay=31 in April or February).
 */
@Service
public class SalaryPeriodService {

    private final Clock clock;

    public SalaryPeriodService(Clock clock) {
        this.clock = clock;
    }

    public record SalaryPeriod(LocalDate start, LocalDate end) {
    }

    /**
     * The salary period that {@code date} falls within, given {@code salaryDay}.
     */
    public SalaryPeriod periodForDate(LocalDate date, int salaryDay) {
        LocalDate thisMonthStart = clampedStart(YearMonth.from(date), salaryDay);

        if (!date.isBefore(thisMonthStart)) {
            LocalDate nextMonthStart = clampedStart(YearMonth.from(date).plusMonths(1), salaryDay);
            return new SalaryPeriod(thisMonthStart, nextMonthStart.minusDays(1));
        }

        LocalDate prevMonthStart = clampedStart(YearMonth.from(date).minusMonths(1), salaryDay);
        return new SalaryPeriod(prevMonthStart, thisMonthStart.minusDays(1));
    }

    public SalaryPeriod currentPeriod(int salaryDay) {
        return periodForDate(LocalDate.now(clock), salaryDay);
    }

    private LocalDate clampedStart(YearMonth month, int salaryDay) {
        int effectiveDay = Math.min(salaryDay, month.lengthOfMonth());
        return month.atDay(effectiveDay);
    }
}

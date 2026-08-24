package com.afterpay.expense.service;

import java.time.Clock;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;

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

    public SalaryPeriod previousPeriod(SalaryPeriod current, int salaryDay) {
        return periodForDate(current.start().minusDays(1), salaryDay);
    }

    /**
     * The current period followed by the {@code count - 1} periods before it,
     * newest first — used to offer a user a list of specific past periods to
     * pick from.
     */
    public List<SalaryPeriod> recentPeriods(int salaryDay, int count) {
        List<SalaryPeriod> periods = new ArrayList<>(count);
        SalaryPeriod period = currentPeriod(salaryDay);
        periods.add(period);
        for (int i = 1; i < count; i++) {
            period = previousPeriod(period, salaryDay);
            periods.add(period);
        }
        return periods;
    }

    private LocalDate clampedStart(YearMonth month, int salaryDay) {
        int effectiveDay = Math.min(salaryDay, month.lengthOfMonth());
        return month.atDay(effectiveDay);
    }
}

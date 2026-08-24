package com.afterpay.expense;

import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneOffset;

import org.junit.jupiter.api.Test;

import com.afterpay.expense.service.SalaryPeriodService;
import com.afterpay.expense.service.SalaryPeriodService.SalaryPeriod;

import static org.junit.jupiter.api.Assertions.assertEquals;

class SalaryPeriodServiceTest {

    private SalaryPeriodService serviceAt(LocalDate today) {
        Clock clock = Clock.fixed(today.atStartOfDay(ZoneOffset.UTC).toInstant(), ZoneOffset.UTC);
        return new SalaryPeriodService(clock);
    }

    @Test
    void beforeSalaryDayFallsInPreviousMonthsPeriod() {
        SalaryPeriodService service = serviceAt(LocalDate.of(2026, 8, 23));
        SalaryPeriod period = service.currentPeriod(25);

        assertEquals(LocalDate.of(2026, 7, 25), period.start());
        assertEquals(LocalDate.of(2026, 8, 24), period.end());
    }

    @Test
    void onSalaryDayStartsNewPeriod() {
        SalaryPeriodService service = serviceAt(LocalDate.of(2026, 8, 25));
        SalaryPeriod period = service.currentPeriod(25);

        assertEquals(LocalDate.of(2026, 8, 25), period.start());
        assertEquals(LocalDate.of(2026, 9, 24), period.end());
    }

    @Test
    void salaryDay31ClampsThroughApril() {
        SalaryPeriodService service = new SalaryPeriodService(Clock.systemUTC());

        SalaryPeriod fromApril15 = service.periodForDate(LocalDate.of(2026, 4, 15), 31);
        assertEquals(LocalDate.of(2026, 3, 31), fromApril15.start());
        assertEquals(LocalDate.of(2026, 4, 29), fromApril15.end());

        SalaryPeriod fromApril30 = service.periodForDate(LocalDate.of(2026, 4, 30), 31);
        assertEquals(LocalDate.of(2026, 4, 30), fromApril30.start());
        assertEquals(LocalDate.of(2026, 5, 30), fromApril30.end());
    }

    @Test
    void salaryDay31ClampsThroughFebruaryNonLeapYear() {
        SalaryPeriodService service = new SalaryPeriodService(Clock.systemUTC());

        // Feb 2027 has 28 days, so the clamped salary day is Feb 28 (the last day).
        // A date one day before it still belongs to January's period.
        SalaryPeriod beforeClampedDay = service.periodForDate(LocalDate.of(2027, 2, 27), 31);
        assertEquals(LocalDate.of(2027, 1, 31), beforeClampedDay.start());
        assertEquals(LocalDate.of(2027, 2, 27), beforeClampedDay.end());

        // The clamped day itself starts the new period.
        SalaryPeriod onClampedDay = service.periodForDate(LocalDate.of(2027, 2, 28), 31);
        assertEquals(LocalDate.of(2027, 2, 28), onClampedDay.start());
        assertEquals(LocalDate.of(2027, 3, 30), onClampedDay.end());
    }

    @Test
    void salaryDay31ClampsThroughFebruaryLeapYear() {
        SalaryPeriodService service = new SalaryPeriodService(Clock.systemUTC());

        SalaryPeriod period = service.periodForDate(LocalDate.of(2028, 2, 29), 31);
        assertEquals(LocalDate.of(2028, 2, 29), period.start());
        assertEquals(LocalDate.of(2028, 3, 30), period.end());
    }

    @Test
    void salaryDay1IsCalendarMonth() {
        SalaryPeriodService service = new SalaryPeriodService(Clock.systemUTC());

        SalaryPeriod period = service.periodForDate(LocalDate.of(2026, 6, 15), 1);
        assertEquals(LocalDate.of(2026, 6, 1), period.start());
        assertEquals(LocalDate.of(2026, 6, 30), period.end());
    }

    @Test
    void previousPeriodImmediatelyPrecedesCurrentPeriod() {
        SalaryPeriodService service = serviceAt(LocalDate.of(2026, 8, 25));
        SalaryPeriod current = service.currentPeriod(25);
        SalaryPeriod previous = service.previousPeriod(current, 25);

        assertEquals(current.start(), previous.end().plusDays(1));
        assertEquals(LocalDate.of(2026, 7, 25), previous.start());
        assertEquals(LocalDate.of(2026, 8, 24), previous.end());
    }

    @Test
    void recentPeriodsReturnsNewestFirstAndChainsContiguously() {
        SalaryPeriodService service = serviceAt(LocalDate.of(2026, 8, 25));
        var periods = service.recentPeriods(25, 4);

        assertEquals(4, periods.size());
        assertEquals(LocalDate.of(2026, 8, 25), periods.get(0).start());
        assertEquals(LocalDate.of(2026, 7, 25), periods.get(1).start());
        assertEquals(LocalDate.of(2026, 6, 25), periods.get(2).start());
        assertEquals(LocalDate.of(2026, 5, 25), periods.get(3).start());

        for (int i = 1; i < periods.size(); i++) {
            assertEquals(periods.get(i - 1).start(), periods.get(i).end().plusDays(1));
        }
    }
}

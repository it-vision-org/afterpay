package com.afterpay.expense.api;

import java.time.format.TextStyle;
import java.util.List;
import java.util.Locale;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.afterpay.common.security.CurrentUserProvider;
import com.afterpay.expense.api.dto.SalaryPeriodResponse;
import com.afterpay.expense.service.SalaryPeriodService;
import com.afterpay.expense.service.SalaryPeriodService.SalaryPeriod;
import com.afterpay.identity.domain.User;

@RestController
@RequestMapping("/api/salary-periods")
public class SalaryPeriodController {

    private static final int MAX_COUNT = 24;

    private final SalaryPeriodService salaryPeriodService;
    private final CurrentUserProvider currentUserProvider;

    public SalaryPeriodController(SalaryPeriodService salaryPeriodService, CurrentUserProvider currentUserProvider) {
        this.salaryPeriodService = salaryPeriodService;
        this.currentUserProvider = currentUserProvider;
    }

    @GetMapping
    public List<SalaryPeriodResponse> list(
        @AuthenticationPrincipal Jwt jwt,
        @RequestParam(defaultValue = "12") int count
    ) {
        User user = currentUserProvider.require(jwt);
        int clampedCount = Math.max(1, Math.min(count, MAX_COUNT));

        return salaryPeriodService.recentPeriods(user.getSalaryDay(), clampedCount).stream()
            .map(this::toResponse)
            .toList();
    }

    private SalaryPeriodResponse toResponse(SalaryPeriod period) {
        String label = period.end().getMonth().getDisplayName(TextStyle.FULL, Locale.ENGLISH)
            + " " + period.end().getYear();
        return new SalaryPeriodResponse(period.start(), period.end(), label);
    }
}

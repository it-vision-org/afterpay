package com.afterpay.dashboard.service;

import java.math.BigDecimal;
import java.math.RoundingMode;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.afterpay.dashboard.api.dto.DashboardResponse;
import com.afterpay.expense.mapper.ExpenseMapper;
import com.afterpay.expense.repository.ExpenseRepository;
import com.afterpay.expense.repository.RecurringExpenseRepository;
import com.afterpay.expense.service.SalaryPeriodService;
import com.afterpay.expense.service.SalaryPeriodService.SalaryPeriod;
import com.afterpay.identity.domain.User;
import com.afterpay.salary.repository.SalarySourceRepository;

@Service
public class DashboardService {

    private static final BigDecimal ONE_HUNDRED = BigDecimal.valueOf(100);
    private static final int RECENT_EXPENSES_LIMIT = 5;

    private final ExpenseRepository expenseRepository;
    private final RecurringExpenseRepository recurringExpenseRepository;
    private final SalarySourceRepository salarySourceRepository;
    private final SalaryPeriodService salaryPeriodService;
    private final ExpenseMapper expenseMapper;

    public DashboardService(
        ExpenseRepository expenseRepository,
        RecurringExpenseRepository recurringExpenseRepository,
        SalarySourceRepository salarySourceRepository,
        SalaryPeriodService salaryPeriodService,
        ExpenseMapper expenseMapper
    ) {
        this.expenseRepository = expenseRepository;
        this.recurringExpenseRepository = recurringExpenseRepository;
        this.salarySourceRepository = salarySourceRepository;
        this.salaryPeriodService = salaryPeriodService;
        this.expenseMapper = expenseMapper;
    }

    @Transactional(readOnly = true)
    public DashboardResponse get(User user) {
        SalaryPeriod period = salaryPeriodService.currentPeriod(user.getSalaryDay());

        BigDecimal salary = salarySourceRepository.sumAmountByUserId(user.getId());
        BigDecimal recurringTotal = recurringExpenseRepository.sumAmountByUserIdAndActiveTrue(user.getId());
        BigDecimal oneTimeTotal = expenseRepository.sumAmountByUserIdAndExpenseDateBetween(user.getId(), period.start(), period.end());
        BigDecimal totalSpent = recurringTotal.add(oneTimeTotal);
        BigDecimal remaining = salary.subtract(totalSpent);

        BigDecimal percentageUsed = salary.signum() == 0
            ? BigDecimal.ZERO
            : totalSpent.divide(salary, 4, RoundingMode.HALF_UP).multiply(ONE_HUNDRED);

        var recentExpenses = expenseRepository
            .findAllByUserIdAndExpenseDateBetweenOrderByExpenseDateDescCreatedAtDesc(user.getId(), period.start(), period.end())
            .stream()
            .limit(RECENT_EXPENSES_LIMIT)
            .map(expenseMapper::toResponse)
            .toList();

        return new DashboardResponse(
            salary,
            recurringTotal,
            oneTimeTotal,
            totalSpent,
            remaining,
            percentageUsed,
            remaining.signum() < 0,
            period.start(),
            period.end(),
            recentExpenses
        );
    }
}

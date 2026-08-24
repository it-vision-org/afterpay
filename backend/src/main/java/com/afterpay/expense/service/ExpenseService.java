package com.afterpay.expense.service;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.afterpay.common.api.ApiException;
import com.afterpay.expense.api.dto.ExpensePeriodFilter;
import com.afterpay.expense.api.dto.ExpenseRequest;
import com.afterpay.expense.api.dto.ExpenseResponse;
import com.afterpay.expense.domain.Expense;
import com.afterpay.expense.mapper.ExpenseMapper;
import com.afterpay.expense.repository.ExpenseRepository;
import com.afterpay.expense.service.SalaryPeriodService.SalaryPeriod;
import com.afterpay.identity.domain.User;

@Service
public class ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final SalaryPeriodService salaryPeriodService;
    private final ExpenseMapper mapper;

    public ExpenseService(ExpenseRepository expenseRepository, SalaryPeriodService salaryPeriodService, ExpenseMapper mapper) {
        this.expenseRepository = expenseRepository;
        this.salaryPeriodService = salaryPeriodService;
        this.mapper = mapper;
    }

    @Transactional(readOnly = true)
    public List<ExpenseResponse> list(User user, ExpensePeriodFilter filter, List<LocalDate> periodStarts) {
        if (periodStarts != null && !periodStarts.isEmpty()) {
            return periodStarts.stream()
                .map(start -> salaryPeriodService.periodForDate(start, user.getSalaryDay()))
                .distinct()
                .flatMap(period -> expenseRepository
                    .findAllByUserIdAndExpenseDateBetweenOrderByExpenseDateDescCreatedAtDesc(user.getId(), period.start(), period.end())
                    .stream())
                .sorted(Comparator.comparing(Expense::getExpenseDate).thenComparing(Expense::getCreatedAt).reversed())
                .map(mapper::toResponse)
                .toList();
        }

        ExpensePeriodFilter effectiveFilter = filter == null ? ExpensePeriodFilter.CURRENT : filter;

        if (effectiveFilter == ExpensePeriodFilter.ALL) {
            return expenseRepository.findAllByUserIdOrderByExpenseDateDescCreatedAtDesc(user.getId()).stream()
                .map(mapper::toResponse)
                .toList();
        }

        SalaryPeriod period = salaryPeriodService.currentPeriod(user.getSalaryDay());
        return expenseRepository
            .findAllByUserIdAndExpenseDateBetweenOrderByExpenseDateDescCreatedAtDesc(user.getId(), period.start(), period.end())
            .stream()
            .map(mapper::toResponse)
            .toList();
    }

    @Transactional(readOnly = true)
    public ExpenseResponse get(User user, UUID id) {
        return mapper.toResponse(requireOwned(user, id));
    }

    @Transactional
    public ExpenseResponse create(User user, ExpenseRequest request) {
        Expense expense = new Expense(
            user,
            request.name(),
            request.amount(),
            request.category(),
            request.expenseDate(),
            request.note(),
            request.icon(),
            request.color()
        );
        return mapper.toResponse(expenseRepository.saveAndFlush(expense));
    }

    @Transactional
    public ExpenseResponse update(User user, UUID id, ExpenseRequest request) {
        Expense expense = requireOwned(user, id);
        expense.setName(request.name());
        expense.setAmount(request.amount());
        expense.setCategory(request.category());
        expense.setExpenseDate(request.expenseDate());
        expense.setNote(request.note());
        expense.setIcon(request.icon());
        expense.setColor(request.color());
        return mapper.toResponse(expenseRepository.saveAndFlush(expense));
    }

    @Transactional
    public void delete(User user, UUID id) {
        expenseRepository.delete(requireOwned(user, id));
    }

    private Expense requireOwned(User user, UUID id) {
        return expenseRepository.findByIdAndUserId(id, user.getId())
            .orElseThrow(() -> ApiException.notFound("EXPENSE_NOT_FOUND", "Expense not found"));
    }
}

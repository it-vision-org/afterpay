package com.afterpay.expense.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.afterpay.common.api.ApiException;
import com.afterpay.expense.api.dto.RecurringExpenseRequest;
import com.afterpay.expense.api.dto.RecurringExpenseResponse;
import com.afterpay.expense.domain.RecurringExpense;
import com.afterpay.expense.mapper.RecurringExpenseMapper;
import com.afterpay.expense.repository.RecurringExpenseRepository;
import com.afterpay.identity.domain.User;

@Service
public class RecurringExpenseService {

    private final RecurringExpenseRepository recurringExpenseRepository;
    private final RecurringExpenseMapper mapper;

    public RecurringExpenseService(RecurringExpenseRepository recurringExpenseRepository, RecurringExpenseMapper mapper) {
        this.recurringExpenseRepository = recurringExpenseRepository;
        this.mapper = mapper;
    }

    @Transactional(readOnly = true)
    public List<RecurringExpenseResponse> list(User user, Boolean activeFilter) {
        List<RecurringExpense> results = activeFilter == null
            ? recurringExpenseRepository.findAllByUserIdOrderByNameAsc(user.getId())
            : recurringExpenseRepository.findAllByUserIdAndActiveOrderByNameAsc(user.getId(), activeFilter);

        return results.stream().map(mapper::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public RecurringExpenseResponse get(User user, UUID id) {
        return mapper.toResponse(requireOwned(user, id));
    }

    @Transactional
    public RecurringExpenseResponse create(User user, RecurringExpenseRequest request) {
        RecurringExpense recurringExpense = new RecurringExpense(
            user,
            request.name(),
            request.amount(),
            request.category(),
            request.description(),
            request.active(),
            request.icon(),
            request.color()
        );
        return mapper.toResponse(recurringExpenseRepository.saveAndFlush(recurringExpense));
    }

    @Transactional
    public RecurringExpenseResponse update(User user, UUID id, RecurringExpenseRequest request) {
        RecurringExpense recurringExpense = requireOwned(user, id);
        recurringExpense.setName(request.name());
        recurringExpense.setAmount(request.amount());
        recurringExpense.setCategory(request.category());
        recurringExpense.setDescription(request.description());
        recurringExpense.setActive(request.active());
        recurringExpense.setIcon(request.icon());
        recurringExpense.setColor(request.color());
        return mapper.toResponse(recurringExpenseRepository.saveAndFlush(recurringExpense));
    }

    @Transactional
    public RecurringExpenseResponse setActive(User user, UUID id, boolean active) {
        RecurringExpense recurringExpense = requireOwned(user, id);
        recurringExpense.setActive(active);
        return mapper.toResponse(recurringExpenseRepository.saveAndFlush(recurringExpense));
    }

    @Transactional
    public void delete(User user, UUID id) {
        recurringExpenseRepository.delete(requireOwned(user, id));
    }

    private RecurringExpense requireOwned(User user, UUID id) {
        return recurringExpenseRepository.findByIdAndUserId(id, user.getId())
            .orElseThrow(() -> ApiException.notFound("RECURRING_EXPENSE_NOT_FOUND", "Recurring expense not found"));
    }
}

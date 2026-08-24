package com.afterpay.expense.api;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.afterpay.common.security.CurrentUserProvider;
import com.afterpay.expense.api.dto.ExpensePeriodFilter;
import com.afterpay.expense.api.dto.ExpenseRequest;
import com.afterpay.expense.api.dto.ExpenseResponse;
import com.afterpay.expense.service.ExpenseService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/expenses")
public class ExpenseController {

    private final ExpenseService expenseService;
    private final CurrentUserProvider currentUserProvider;

    public ExpenseController(ExpenseService expenseService, CurrentUserProvider currentUserProvider) {
        this.expenseService = expenseService;
        this.currentUserProvider = currentUserProvider;
    }

    @GetMapping
    public List<ExpenseResponse> list(
        @AuthenticationPrincipal Jwt jwt,
        @RequestParam(required = false) ExpensePeriodFilter period,
        @RequestParam(required = false) List<LocalDate> periodStart
    ) {
        return expenseService.list(currentUserProvider.require(jwt), period, periodStart);
    }

    @GetMapping("/{id}")
    public ExpenseResponse get(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        return expenseService.get(currentUserProvider.require(jwt), id);
    }

    @PostMapping
    public ExpenseResponse create(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody ExpenseRequest request) {
        return expenseService.create(currentUserProvider.require(jwt), request);
    }

    @PutMapping("/{id}")
    public ExpenseResponse update(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id, @Valid @RequestBody ExpenseRequest request) {
        return expenseService.update(currentUserProvider.require(jwt), id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        expenseService.delete(currentUserProvider.require(jwt), id);
        return ResponseEntity.noContent().build();
    }
}

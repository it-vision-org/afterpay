package com.afterpay.expense.api;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.afterpay.common.security.CurrentUserProvider;
import com.afterpay.expense.api.dto.RecurringExpenseRequest;
import com.afterpay.expense.api.dto.RecurringExpenseResponse;
import com.afterpay.expense.api.dto.UpdateActiveRequest;
import com.afterpay.expense.service.RecurringExpenseService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/recurring-expenses")
public class RecurringExpenseController {

    private final RecurringExpenseService recurringExpenseService;
    private final CurrentUserProvider currentUserProvider;

    public RecurringExpenseController(RecurringExpenseService recurringExpenseService, CurrentUserProvider currentUserProvider) {
        this.recurringExpenseService = recurringExpenseService;
        this.currentUserProvider = currentUserProvider;
    }

    @GetMapping
    public List<RecurringExpenseResponse> list(
        @AuthenticationPrincipal Jwt jwt,
        @RequestParam(required = false) Boolean active
    ) {
        return recurringExpenseService.list(currentUserProvider.require(jwt), active);
    }

    @GetMapping("/{id}")
    public RecurringExpenseResponse get(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        return recurringExpenseService.get(currentUserProvider.require(jwt), id);
    }

    @PostMapping
    public RecurringExpenseResponse create(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody RecurringExpenseRequest request) {
        return recurringExpenseService.create(currentUserProvider.require(jwt), request);
    }

    @PutMapping("/{id}")
    public RecurringExpenseResponse update(
        @AuthenticationPrincipal Jwt jwt,
        @PathVariable UUID id,
        @Valid @RequestBody RecurringExpenseRequest request
    ) {
        return recurringExpenseService.update(currentUserProvider.require(jwt), id, request);
    }

    @PatchMapping("/{id}/active")
    public RecurringExpenseResponse setActive(
        @AuthenticationPrincipal Jwt jwt,
        @PathVariable UUID id,
        @Valid @RequestBody UpdateActiveRequest request
    ) {
        return recurringExpenseService.setActive(currentUserProvider.require(jwt), id, request.active());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        recurringExpenseService.delete(currentUserProvider.require(jwt), id);
        return ResponseEntity.noContent().build();
    }
}

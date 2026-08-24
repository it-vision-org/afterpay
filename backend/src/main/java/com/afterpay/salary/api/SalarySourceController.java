package com.afterpay.salary.api;

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
import org.springframework.web.bind.annotation.RestController;

import com.afterpay.common.security.CurrentUserProvider;
import com.afterpay.salary.api.dto.SalarySourceRequest;
import com.afterpay.salary.api.dto.SalarySourceResponse;
import com.afterpay.salary.service.SalarySourceService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/salary-sources")
public class SalarySourceController {

    private final SalarySourceService salarySourceService;
    private final CurrentUserProvider currentUserProvider;

    public SalarySourceController(SalarySourceService salarySourceService, CurrentUserProvider currentUserProvider) {
        this.salarySourceService = salarySourceService;
        this.currentUserProvider = currentUserProvider;
    }

    @GetMapping
    public List<SalarySourceResponse> list(@AuthenticationPrincipal Jwt jwt) {
        return salarySourceService.list(currentUserProvider.require(jwt));
    }

    @GetMapping("/{id}")
    public SalarySourceResponse get(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        return salarySourceService.get(currentUserProvider.require(jwt), id);
    }

    @PostMapping
    public SalarySourceResponse create(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody SalarySourceRequest request) {
        return salarySourceService.create(currentUserProvider.require(jwt), request);
    }

    @PutMapping("/{id}")
    public SalarySourceResponse update(
        @AuthenticationPrincipal Jwt jwt,
        @PathVariable UUID id,
        @Valid @RequestBody SalarySourceRequest request
    ) {
        return salarySourceService.update(currentUserProvider.require(jwt), id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID id) {
        salarySourceService.delete(currentUserProvider.require(jwt), id);
        return ResponseEntity.noContent().build();
    }
}

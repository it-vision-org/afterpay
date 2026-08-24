package com.afterpay.salary.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.afterpay.common.api.ApiException;
import com.afterpay.identity.domain.User;
import com.afterpay.salary.api.dto.SalarySourceRequest;
import com.afterpay.salary.api.dto.SalarySourceResponse;
import com.afterpay.salary.domain.SalarySource;
import com.afterpay.salary.mapper.SalarySourceMapper;
import com.afterpay.salary.repository.SalarySourceRepository;

@Service
public class SalarySourceService {

    private final SalarySourceRepository salarySourceRepository;
    private final SalarySourceMapper mapper;

    public SalarySourceService(SalarySourceRepository salarySourceRepository, SalarySourceMapper mapper) {
        this.salarySourceRepository = salarySourceRepository;
        this.mapper = mapper;
    }

    @Transactional(readOnly = true)
    public List<SalarySourceResponse> list(User user) {
        return salarySourceRepository.findAllByUserIdOrderByNameAsc(user.getId()).stream()
            .map(mapper::toResponse)
            .toList();
    }

    @Transactional(readOnly = true)
    public SalarySourceResponse get(User user, UUID id) {
        return mapper.toResponse(requireOwned(user, id));
    }

    @Transactional
    public SalarySourceResponse create(User user, SalarySourceRequest request) {
        SalarySource salarySource = new SalarySource(user, request.name(), request.amount(), request.payDay());
        return mapper.toResponse(salarySourceRepository.saveAndFlush(salarySource));
    }

    @Transactional
    public SalarySourceResponse update(User user, UUID id, SalarySourceRequest request) {
        SalarySource salarySource = requireOwned(user, id);
        salarySource.setName(request.name());
        salarySource.setAmount(request.amount());
        salarySource.setPayDay(request.payDay());
        return mapper.toResponse(salarySourceRepository.saveAndFlush(salarySource));
    }

    @Transactional
    public void delete(User user, UUID id) {
        salarySourceRepository.delete(requireOwned(user, id));
    }

    private SalarySource requireOwned(User user, UUID id) {
        return salarySourceRepository.findByIdAndUserId(id, user.getId())
            .orElseThrow(() -> ApiException.notFound("SALARY_SOURCE_NOT_FOUND", "Salary source not found"));
    }
}

package com.afterpay.salary.mapper;

import org.mapstruct.Mapper;

import com.afterpay.salary.api.dto.SalarySourceResponse;
import com.afterpay.salary.domain.SalarySource;

@Mapper(componentModel = "spring")
public interface SalarySourceMapper {

    SalarySourceResponse toResponse(SalarySource salarySource);
}

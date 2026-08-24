package com.afterpay.expense.mapper;

import org.mapstruct.Mapper;

import com.afterpay.expense.api.dto.ExpenseResponse;
import com.afterpay.expense.domain.Expense;

@Mapper(componentModel = "spring")
public interface ExpenseMapper {

    ExpenseResponse toResponse(Expense expense);
}

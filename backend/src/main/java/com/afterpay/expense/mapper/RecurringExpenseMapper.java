package com.afterpay.expense.mapper;

import org.mapstruct.Mapper;

import com.afterpay.expense.api.dto.RecurringExpenseResponse;
import com.afterpay.expense.domain.RecurringExpense;

@Mapper(componentModel = "spring")
public interface RecurringExpenseMapper {

    RecurringExpenseResponse toResponse(RecurringExpense recurringExpense);
}

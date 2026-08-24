package com.afterpay.expense.repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.afterpay.expense.domain.RecurringExpense;

public interface RecurringExpenseRepository extends JpaRepository<RecurringExpense, UUID> {

    Optional<RecurringExpense> findByIdAndUserId(UUID id, UUID userId);

    List<RecurringExpense> findAllByUserIdOrderByNameAsc(UUID userId);

    List<RecurringExpense> findAllByUserIdAndActiveOrderByNameAsc(UUID userId, boolean active);

    @Query("""
        select coalesce(sum(r.amount), 0) from RecurringExpense r
        where r.user.id = :userId and r.active = true
        """)
    BigDecimal sumAmountByUserIdAndActiveTrue(@Param("userId") UUID userId);
}

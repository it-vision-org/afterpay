package com.afterpay.expense.repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.afterpay.expense.domain.Expense;

public interface ExpenseRepository extends JpaRepository<Expense, UUID> {

    Optional<Expense> findByIdAndUserId(UUID id, UUID userId);

    List<Expense> findAllByUserIdOrderByExpenseDateDescCreatedAtDesc(UUID userId);

    List<Expense> findAllByUserIdAndExpenseDateBetweenOrderByExpenseDateDescCreatedAtDesc(
        UUID userId, LocalDate start, LocalDate end
    );

    @Query("""
        select coalesce(sum(e.amount), 0) from Expense e
        where e.user.id = :userId and e.expenseDate between :start and :end
        """)
    BigDecimal sumAmountByUserIdAndExpenseDateBetween(
        @Param("userId") UUID userId,
        @Param("start") LocalDate start,
        @Param("end") LocalDate end
    );
}

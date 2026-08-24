package com.afterpay.salary.repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.afterpay.salary.domain.SalarySource;

public interface SalarySourceRepository extends JpaRepository<SalarySource, UUID> {

    Optional<SalarySource> findByIdAndUserId(UUID id, UUID userId);

    List<SalarySource> findAllByUserIdOrderByNameAsc(UUID userId);

    @Query("select coalesce(sum(s.amount), 0) from SalarySource s where s.user.id = :userId")
    BigDecimal sumAmountByUserId(@Param("userId") UUID userId);
}

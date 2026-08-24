package com.afterpay.salary.domain;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.afterpay.identity.domain.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * One income source contributing to a user's total salary — most users have
 * exactly one, but some have several (a second job, rental income, a
 * household shared between two earners). Each can carry its own informal pay
 * day; only {@code User.salaryDay} drives the actual salary-period math, so
 * differing pay days across sources don't need to be reconciled into one
 * period boundary.
 */
@Entity
@Table(name = "salary_sources")
@Getter
@Setter
@NoArgsConstructor
public class SalarySource {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Column(name = "amount", nullable = false, precision = 14, scale = 2)
    private BigDecimal amount;

    @Column(name = "pay_day")
    private Integer payDay;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public SalarySource(User user, String name, BigDecimal amount, Integer payDay) {
        this.user = user;
        this.name = name;
        this.amount = amount;
        this.payDay = payDay;
    }
}

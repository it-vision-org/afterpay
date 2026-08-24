package com.afterpay.expense;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.afterpay.common.api.ApiException;
import com.afterpay.expense.api.dto.RecurringExpenseRequest;
import com.afterpay.expense.api.dto.RecurringExpenseResponse;
import com.afterpay.expense.domain.Category;
import com.afterpay.expense.repository.RecurringExpenseRepository;
import com.afterpay.expense.service.RecurringExpenseService;
import com.afterpay.identity.domain.User;
import com.afterpay.identity.repository.UserRepository;
import com.afterpay.support.IntegrationTestSupport;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RecurringExpenseServiceIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private RecurringExpenseService recurringExpenseService;

    @Autowired
    private RecurringExpenseRepository recurringExpenseRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private User createUser(String email) {
        User user = new User("Test User", email, passwordEncoder.encode("password123"));
        return userRepository.save(user);
    }

    private static void assertAmountEquals(String expected, BigDecimal actual) {
        assertEquals(0, new BigDecimal(expected).compareTo(actual), () -> "expected " + expected + " but was " + actual);
    }

    @Test
    void createUpdateAndDeleteRecurringExpense() {
        User user = createUser("owner-" + System.nanoTime() + "@afterpay.test");

        RecurringExpenseResponse created = recurringExpenseService.create(user, new RecurringExpenseRequest(
            "Rent", new BigDecimal("700.00"), Category.HOUSING, null, true, null, null
        ));
        assertTrue(created.active());
        assertAmountEquals("700.00", created.amount());

        RecurringExpenseResponse updated = recurringExpenseService.update(user, created.id(), new RecurringExpenseRequest(
            "Rent (updated)", new BigDecimal("750.00"), Category.HOUSING, "New lease", true, null, null
        ));
        assertAmountEquals("750.00", updated.amount());
        assertEquals("New lease", updated.description());

        recurringExpenseService.delete(user, created.id());
        assertThrows(ApiException.class, () -> recurringExpenseService.get(user, created.id()));
    }

    @Test
    void inactiveRecurringExpensesAreExcludedFromActiveSum() {
        User user = createUser("owner-" + System.nanoTime() + "@afterpay.test");

        RecurringExpenseResponse active = recurringExpenseService.create(user, new RecurringExpenseRequest(
            "Internet", new BigDecimal("30.00"), Category.BILLS, null, true, null, null
        ));
        RecurringExpenseResponse toDisable = recurringExpenseService.create(user, new RecurringExpenseRequest(
            "Gym", new BigDecimal("40.00"), Category.HEALTH, null, true, null, null
        ));

        assertAmountEquals("70.00", recurringExpenseRepository.sumAmountByUserIdAndActiveTrue(user.getId()));

        RecurringExpenseResponse disabled = recurringExpenseService.setActive(user, toDisable.id(), false);
        assertFalse(disabled.active());

        assertAmountEquals("30.00", recurringExpenseRepository.sumAmountByUserIdAndActiveTrue(user.getId()));

        var activeOnly = recurringExpenseService.list(user, true);
        assertEquals(1, activeOnly.size());
        assertEquals(active.id(), activeOnly.get(0).id());
    }

    @Test
    void aUserCannotAccessAnotherUsersRecurringExpense() {
        User owner = createUser("owner-" + System.nanoTime() + "@afterpay.test");
        User intruder = createUser("intruder-" + System.nanoTime() + "@afterpay.test");

        RecurringExpenseResponse created = recurringExpenseService.create(owner, new RecurringExpenseRequest(
            "Netflix", new BigDecimal("15.00"), Category.SUBSCRIPTIONS, null, true, null, null
        ));

        assertThrows(ApiException.class, () -> recurringExpenseService.get(intruder, created.id()));
    }
}

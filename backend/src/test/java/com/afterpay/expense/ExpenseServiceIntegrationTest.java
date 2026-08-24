package com.afterpay.expense;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.afterpay.common.api.ApiException;
import com.afterpay.expense.api.dto.ExpensePeriodFilter;
import com.afterpay.expense.api.dto.ExpenseRequest;
import com.afterpay.expense.api.dto.ExpenseResponse;
import com.afterpay.expense.domain.Category;
import com.afterpay.expense.service.ExpenseService;
import com.afterpay.identity.domain.User;
import com.afterpay.identity.repository.UserRepository;
import com.afterpay.support.IntegrationTestSupport;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ExpenseServiceIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private ExpenseService expenseService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private User createUser(String email) {
        User user = new User("Test User", email, passwordEncoder.encode("password123"));
        user.setSalaryDay(1);
        return userRepository.save(user);
    }

    private static void assertAmountEquals(String expected, BigDecimal actual) {
        assertEquals(0, new BigDecimal(expected).compareTo(actual), () -> "expected " + expected + " but was " + actual);
    }

    @Test
    void createUpdateAndDeleteExpense() {
        User user = createUser("owner-" + System.nanoTime() + "@afterpay.test");

        ExpenseResponse created = expenseService.create(user, new ExpenseRequest(
            "Groceries", new BigDecimal("83.50"), Category.FOOD, LocalDate.now(), "Weekly shop", null, null
        ));
        assertAmountEquals("83.50", created.amount());
        assertEquals(Category.FOOD, created.category());

        ExpenseResponse updated = expenseService.update(user, created.id(), new ExpenseRequest(
            "Groceries (updated)", new BigDecimal("95.00"), Category.FOOD, LocalDate.now(), null, null, null
        ));
        assertAmountEquals("95.00", updated.amount());
        assertEquals("Groceries (updated)", updated.name());

        expenseService.delete(user, created.id());
        assertThrows(ApiException.class, () -> expenseService.get(user, created.id()));
    }

    @Test
    void listFiltersByCurrentSpecificAndAllSalaryPeriods() {
        User user = createUser("periods-" + System.nanoTime() + "@afterpay.test");

        LocalDate today = LocalDate.now();
        LocalDate lastMonth = today.minusMonths(1);
        LocalDate twoMonthsAgo = today.minusMonths(2);

        ExpenseResponse currentExpense = expenseService.create(user, new ExpenseRequest(
            "Current", new BigDecimal("10.00"), Category.OTHER, today, null, null, null
        ));
        ExpenseResponse previousExpense = expenseService.create(user, new ExpenseRequest(
            "Previous", new BigDecimal("20.00"), Category.OTHER, lastMonth, null, null, null
        ));
        ExpenseResponse olderExpense = expenseService.create(user, new ExpenseRequest(
            "Older", new BigDecimal("30.00"), Category.OTHER, twoMonthsAgo, null, null, null
        ));

        var currentPeriodList = expenseService.list(user, ExpensePeriodFilter.CURRENT, null);
        assertEquals(1, currentPeriodList.size());
        assertEquals(currentExpense.id(), currentPeriodList.get(0).id());

        var specificPeriodList = expenseService.list(user, null, List.of(lastMonth));
        assertEquals(1, specificPeriodList.size());
        assertEquals(previousExpense.id(), specificPeriodList.get(0).id());

        var unionOfTwoPeriods = expenseService.list(user, null, List.of(lastMonth, twoMonthsAgo));
        assertEquals(2, unionOfTwoPeriods.size());
        assertEquals(
            List.of(previousExpense.id(), olderExpense.id()),
            unionOfTwoPeriods.stream().map(ExpenseResponse::id).toList()
        );

        var allList = expenseService.list(user, ExpensePeriodFilter.ALL, null);
        assertEquals(3, allList.size());
    }

    @Test
    void aUserCannotAccessAnotherUsersExpense() {
        User owner = createUser("owner-" + System.nanoTime() + "@afterpay.test");
        User intruder = createUser("intruder-" + System.nanoTime() + "@afterpay.test");

        ExpenseResponse created = expenseService.create(owner, new ExpenseRequest(
            "Coffee", new BigDecimal("4.00"), Category.FOOD, LocalDate.now(), null, null, null
        ));

        assertThrows(ApiException.class, () -> expenseService.get(intruder, created.id()));
        assertTrue(expenseService.list(intruder, ExpensePeriodFilter.ALL, null).isEmpty());
    }
}

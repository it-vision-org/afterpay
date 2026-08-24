package com.afterpay.salary;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.afterpay.common.api.ApiException;
import com.afterpay.identity.domain.User;
import com.afterpay.identity.repository.UserRepository;
import com.afterpay.salary.api.dto.SalarySourceRequest;
import com.afterpay.salary.api.dto.SalarySourceResponse;
import com.afterpay.salary.repository.SalarySourceRepository;
import com.afterpay.salary.service.SalarySourceService;
import com.afterpay.support.IntegrationTestSupport;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class SalarySourceServiceIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private SalarySourceService salarySourceService;

    @Autowired
    private SalarySourceRepository salarySourceRepository;

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
    void createUpdateAndDeleteSalarySource() {
        User user = createUser("owner-" + System.nanoTime() + "@afterpay.test");

        SalarySourceResponse created = salarySourceService.create(user, new SalarySourceRequest(
            "Main job", new BigDecimal("2500.00"), 25
        ));
        assertAmountEquals("2500.00", created.amount());
        assertEquals(25, created.payDay());

        SalarySourceResponse updated = salarySourceService.update(user, created.id(), new SalarySourceRequest(
            "Main job (raise)", new BigDecimal("2800.00"), 25
        ));
        assertAmountEquals("2800.00", updated.amount());
        assertEquals("Main job (raise)", updated.name());

        salarySourceService.delete(user, created.id());
        assertThrows(ApiException.class, () -> salarySourceService.get(user, created.id()));
    }

    @Test
    void multipleSalarySourcesSumTogether() {
        User user = createUser("owner-" + System.nanoTime() + "@afterpay.test");

        salarySourceService.create(user, new SalarySourceRequest("Main job", new BigDecimal("2500.00"), 25));
        salarySourceService.create(user, new SalarySourceRequest("Rental income", new BigDecimal("400.00"), 5));

        assertAmountEquals("2900.00", salarySourceRepository.sumAmountByUserId(user.getId()));
        assertEquals(2, salarySourceService.list(user).size());
    }

    @Test
    void payDayIsOptional() {
        User user = createUser("owner-" + System.nanoTime() + "@afterpay.test");

        SalarySourceResponse created = salarySourceService.create(user, new SalarySourceRequest(
            "Freelance", new BigDecimal("300.00"), null
        ));
        assertEquals(null, created.payDay());
    }

    @Test
    void aUserCannotAccessAnotherUsersSalarySource() {
        User owner = createUser("owner-" + System.nanoTime() + "@afterpay.test");
        User intruder = createUser("intruder-" + System.nanoTime() + "@afterpay.test");

        SalarySourceResponse created = salarySourceService.create(owner, new SalarySourceRequest(
            "Main job", new BigDecimal("2500.00"), 25
        ));

        assertThrows(ApiException.class, () -> salarySourceService.get(intruder, created.id()));
        assertEquals(0, salarySourceService.list(intruder).size());
    }
}

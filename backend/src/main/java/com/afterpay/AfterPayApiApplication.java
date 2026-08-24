package com.afterpay;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class AfterPayApiApplication {

	public static void main(String[] args) {
		SpringApplication.run(AfterPayApiApplication.class, args);
	}

}

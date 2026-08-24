-- Replaces the single monthly_salary scalar on users with a salary_sources
-- table, so a user can represent more than one income (a second job, rental
-- income, a household shared between two earners) while the dashboard still
-- shows one combined total. Existing monthly_salary values are preserved as
-- each user's first salary source before the column is dropped.

create extension if not exists pgcrypto;

create table salary_sources (
    id uuid primary key,
    user_id uuid not null references users (id) on delete cascade,
    name varchar(200) not null,
    amount numeric(14, 2) not null check (amount > 0),
    pay_day integer check (pay_day between 1 and 31),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index idx_salary_sources_user_id on salary_sources (user_id);

insert into salary_sources (id, user_id, name, amount, pay_day, created_at, updated_at)
select gen_random_uuid(), id, 'Salary', monthly_salary, salary_day, now(), now()
from users
where monthly_salary > 0;

alter table users drop column monthly_salary;

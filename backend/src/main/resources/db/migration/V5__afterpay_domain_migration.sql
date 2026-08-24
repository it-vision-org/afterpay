-- AfterPay domain migration: retires the Lendly lending/borrowing domain
-- (contacts/transactions/repayments hold only Lendly-specific dev data and
-- are no longer part of the product) and introduces the salary/expense
-- domain. Auth tables (users, refresh_tokens, email_verifications) are
-- untouched aside from adding financial-profile columns to users.

drop table if exists repayments;
drop table if exists transactions;
drop table if exists contacts;

alter table users add column monthly_salary numeric(14, 2) not null default 0 check (monthly_salary >= 0);
alter table users add column currency varchar(3) not null default 'TND';
alter table users add column salary_day integer not null default 1 check (salary_day between 1 and 31);

create table expenses (
    id uuid primary key,
    user_id uuid not null references users (id) on delete cascade,
    name varchar(200) not null,
    amount numeric(14, 2) not null check (amount > 0),
    category varchar(30) not null check (category in (
        'HOUSING', 'FOOD', 'TRANSPORTATION', 'SHOPPING', 'ENTERTAINMENT', 'HEALTH',
        'BILLS', 'SUBSCRIPTIONS', 'EDUCATION', 'FAMILY', 'TRAVEL', 'OTHER'
    )),
    expense_date date not null,
    note varchar(500),
    icon varchar(50),
    color varchar(7),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index idx_expenses_user_id on expenses (user_id);
create index idx_expenses_user_id_expense_date on expenses (user_id, expense_date);

create table recurring_expenses (
    id uuid primary key,
    user_id uuid not null references users (id) on delete cascade,
    name varchar(200) not null,
    amount numeric(14, 2) not null check (amount > 0),
    category varchar(30) not null check (category in (
        'HOUSING', 'FOOD', 'TRANSPORTATION', 'SHOPPING', 'ENTERTAINMENT', 'HEALTH',
        'BILLS', 'SUBSCRIPTIONS', 'EDUCATION', 'FAMILY', 'TRAVEL', 'OTHER'
    )),
    description varchar(500),
    active boolean not null default true,
    icon varchar(50),
    color varchar(7),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index idx_recurring_expenses_user_id on recurring_expenses (user_id);
create index idx_recurring_expenses_user_id_active on recurring_expenses (user_id, active);

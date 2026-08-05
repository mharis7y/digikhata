-- ============================================================
-- DigiKhata Clone — Khatabooks Module Tables
-- Run this in Supabase Dashboard → SQL Editor
-- After: 20260805_create_party_module.sql
-- ============================================================

-- ─── 1. stock_items table ───────────────────────────────────────────────────
create table if not exists public.stock_items (
  id                  uuid primary key default gen_random_uuid(),
  owner_id            uuid not null references auth.users(id) on delete cascade,
  name                text not null,
  selling_price       numeric(14, 2) not null default 0.00,
  purchase_price      numeric(14, 2),
  quantity            numeric(14, 2) not null default 0,
  low_stock_warning   numeric(14, 2),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index if not exists idx_stock_items_owner_id on public.stock_items (owner_id);

alter table public.stock_items enable row level security;

create policy "Users can view own stock items" on public.stock_items for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Users can insert own stock items" on public.stock_items for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Users can update own stock items" on public.stock_items for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Users can delete own stock items" on public.stock_items for delete to authenticated using ((select auth.uid()) = owner_id);

-- Super admins can view all stock items
create policy "Super admins can view all stock items" on public.stock_items for select to authenticated using (exists (select 1 from public.profiles where id = (select auth.uid()) and is_super_admin = true));
grant select, insert, update, delete on public.stock_items to authenticated;


-- ─── 2. bills table ─────────────────────────────────────────────────────────
create table if not exists public.bills (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users(id) on delete cascade,
  type            text not null check (type in ('sale', 'purchase')),
  party_id        uuid references public.parties(id) on delete set null,
  party_name      text,
  party_phone     text,
  items           jsonb not null default '[]'::jsonb,
  total_amount    numeric(14, 2) not null default 0.00,
  received_amount numeric(14, 2) not null default 0.00,
  bill_date       timestamptz not null default now(),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists idx_bills_owner_id on public.bills (owner_id);

alter table public.bills enable row level security;

create policy "Users can view own bills" on public.bills for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Users can insert own bills" on public.bills for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Users can update own bills" on public.bills for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Users can delete own bills" on public.bills for delete to authenticated using ((select auth.uid()) = owner_id);

-- Super admins can view all bills
create policy "Super admins can view all bills" on public.bills for select to authenticated using (exists (select 1 from public.profiles where id = (select auth.uid()) and is_super_admin = true));
grant select, insert, update, delete on public.bills to authenticated;


-- ─── 3. cash_entries table ──────────────────────────────────────────────────
create table if not exists public.cash_entries (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users(id) on delete cascade,
  type            text not null check (type in ('cash_in', 'cash_out')),
  amount          numeric(14, 2) not null check (amount > 0),
  note            text,
  linked_bill_id  uuid references public.bills(id) on delete set null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists idx_cash_entries_owner_id on public.cash_entries (owner_id);
create index if not exists idx_cash_entries_linked_bill on public.cash_entries (linked_bill_id);

alter table public.cash_entries enable row level security;

create policy "Users can view own cash entries" on public.cash_entries for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Users can insert own cash entries" on public.cash_entries for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Users can update own cash entries" on public.cash_entries for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Users can delete own cash entries" on public.cash_entries for delete to authenticated using ((select auth.uid()) = owner_id);

-- Super admins can view all cash entries
create policy "Super admins can view all cash entries" on public.cash_entries for select to authenticated using (exists (select 1 from public.profiles where id = (select auth.uid()) and is_super_admin = true));
grant select, insert, update, delete on public.cash_entries to authenticated;


-- ─── 4. staff table ─────────────────────────────────────────────────────────
create table if not exists public.staff (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users(id) on delete cascade,
  name            text not null,
  phone           text not null,
  cnic            text,
  salary_type     text not null check (salary_type in ('monthly', 'weekly', 'daily', 'hourly')),
  salary_amount   numeric(14, 2) not null default 0.00,
  working_hours   text,
  joining_date    date,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists idx_staff_owner_id on public.staff (owner_id);

alter table public.staff enable row level security;

create policy "Users can view own staff" on public.staff for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Users can insert own staff" on public.staff for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Users can update own staff" on public.staff for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Users can delete own staff" on public.staff for delete to authenticated using ((select auth.uid()) = owner_id);

-- Super admins can view all staff
create policy "Super admins can view all staff" on public.staff for select to authenticated using (exists (select 1 from public.profiles where id = (select auth.uid()) and is_super_admin = true));
grant select, insert, update, delete on public.staff to authenticated;


-- ─── 5. staff_attendance table ──────────────────────────────────────────────
create table if not exists public.staff_attendance (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users(id) on delete cascade,
  staff_id        uuid not null references public.staff(id) on delete cascade,
  date            date not null,
  status          text not null check (status in ('present', 'absent', 'half_day', 'late')),
  created_at      timestamptz not null default now(),
  unique(staff_id, date)
);

create index if not exists idx_staff_attendance_staff_id on public.staff_attendance (staff_id);
create index if not exists idx_staff_attendance_owner_id on public.staff_attendance (owner_id);

alter table public.staff_attendance enable row level security;

create policy "Users can view own staff attendance" on public.staff_attendance for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Users can insert own staff attendance" on public.staff_attendance for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Users can update own staff attendance" on public.staff_attendance for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Users can delete own staff attendance" on public.staff_attendance for delete to authenticated using ((select auth.uid()) = owner_id);

-- Super admins can view all staff attendance
create policy "Super admins can view all staff attendance" on public.staff_attendance for select to authenticated using (exists (select 1 from public.profiles where id = (select auth.uid()) and is_super_admin = true));
grant select, insert, update, delete on public.staff_attendance to authenticated;


-- ─── 6. staff_payroll table ─────────────────────────────────────────────────
create table if not exists public.staff_payroll (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users(id) on delete cascade,
  staff_id        uuid not null references public.staff(id) on delete cascade,
  amount          numeric(14, 2) not null check (amount > 0),
  date            date not null,
  note            text,
  created_at      timestamptz not null default now()
);

create index if not exists idx_staff_payroll_staff_id on public.staff_payroll (staff_id);
create index if not exists idx_staff_payroll_owner_id on public.staff_payroll (owner_id);

alter table public.staff_payroll enable row level security;

create policy "Users can view own staff payroll" on public.staff_payroll for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Users can insert own staff payroll" on public.staff_payroll for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Users can update own staff payroll" on public.staff_payroll for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Users can delete own staff payroll" on public.staff_payroll for delete to authenticated using ((select auth.uid()) = owner_id);

-- Super admins can view all staff payroll
create policy "Super admins can view all staff payroll" on public.staff_payroll for select to authenticated using (exists (select 1 from public.profiles where id = (select auth.uid()) and is_super_admin = true));
grant select, insert, update, delete on public.staff_payroll to authenticated;


-- ─── 7. expenses table ──────────────────────────────────────────────────────
create table if not exists public.expenses (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users(id) on delete cascade,
  category        text not null,
  amount          numeric(14, 2) not null check (amount > 0),
  note            text,
  date            date not null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists idx_expenses_owner_id on public.expenses (owner_id);

alter table public.expenses enable row level security;

create policy "Users can view own expenses" on public.expenses for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Users can insert own expenses" on public.expenses for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Users can update own expenses" on public.expenses for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Users can delete own expenses" on public.expenses for delete to authenticated using ((select auth.uid()) = owner_id);

-- Super admins can view all expenses
create policy "Super admins can view all expenses" on public.expenses for select to authenticated using (exists (select 1 from public.profiles where id = (select auth.uid()) and is_super_admin = true));
grant select, insert, update, delete on public.expenses to authenticated;


-- ─── 8. Auto-update triggers ────────────────────────────────────────────────
-- Function already defined in 20260805_create_party_module.sql (public.set_updated_at())

create trigger stock_items_set_updated_at before update on public.stock_items for each row execute function public.set_updated_at();
create trigger bills_set_updated_at before update on public.bills for each row execute function public.set_updated_at();
create trigger cash_entries_set_updated_at before update on public.cash_entries for each row execute function public.set_updated_at();
create trigger staff_set_updated_at before update on public.staff for each row execute function public.set_updated_at();
create trigger expenses_set_updated_at before update on public.expenses for each row execute function public.set_updated_at();

-- ============================================================
-- DigiKhata Clone — Expense Accounts Migration
-- ============================================================

-- 1. Create expense_accounts table
create table if not exists public.expense_accounts (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references auth.users(id) on delete cascade,
  name            text not null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists idx_expense_accounts_owner_id on public.expense_accounts (owner_id);

alter table public.expense_accounts enable row level security;

create policy "Users can view own expense accounts" on public.expense_accounts for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Users can insert own expense accounts" on public.expense_accounts for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Users can update own expense accounts" on public.expense_accounts for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Users can delete own expense accounts" on public.expense_accounts for delete to authenticated using ((select auth.uid()) = owner_id);

create policy "Super admins can view all expense accounts" on public.expense_accounts for select to authenticated using (exists (select 1 from public.profiles where id = (select auth.uid()) and is_super_admin = true));
grant select, insert, update, delete on public.expense_accounts to authenticated;

create trigger expense_accounts_set_updated_at before update on public.expense_accounts for each row execute function public.set_updated_at();

-- 2. Modify expenses table
alter table public.expenses 
  add column if not exists expense_account_id uuid references public.expense_accounts(id) on delete cascade,
  add column if not exists party_id uuid references public.parties(id) on delete set null,
  add column if not exists bill_no text,
  add column if not exists is_cash boolean default true,
  add column if not exists image_url text,
  add column if not exists voice_note_url text;

alter table public.expenses alter column category drop not null;

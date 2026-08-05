-- ============================================================
-- DigiKhata Clone — Party Module Tables
-- Run this in Supabase Dashboard → SQL Editor
-- After: 20260804_create_profiles.sql
-- ============================================================

-- ─── 1. parties table ────────────────────────────────────────────────────────
-- Stores both Customers and Suppliers for a business user.
-- owner_id references auth.users (RLS: each user only sees their own parties).
create table if not exists public.parties (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null references auth.users(id) on delete cascade,
  name         text not null,
  phone        text,
  country_code text default '+92',
  type         text not null check (type in ('customer', 'supplier')),
  balance      numeric(14, 2) not null default 0.00,
  -- positive balance = you will GET (receivable)
  -- negative balance = you will GIVE (payable)
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Index for fast lookup by owner
create index if not exists idx_parties_owner_id
  on public.parties (owner_id);

-- Index for filtering by type
create index if not exists idx_parties_owner_type
  on public.parties (owner_id, type);

-- ─── 2. Enable RLS on parties ─────────────────────────────────────────────────
alter table public.parties enable row level security;

-- Users can only see their own parties
create policy "Users can view own parties"
  on public.parties
  for select
  to authenticated
  using ( (select auth.uid()) = owner_id );

-- Users can insert parties for themselves
create policy "Users can insert own parties"
  on public.parties
  for insert
  to authenticated
  with check ( (select auth.uid()) = owner_id );

-- Users can update their own parties
create policy "Users can update own parties"
  on public.parties
  for update
  to authenticated
  using ( (select auth.uid()) = owner_id )
  with check ( (select auth.uid()) = owner_id );

-- Users can delete their own parties
create policy "Users can delete own parties"
  on public.parties
  for delete
  to authenticated
  using ( (select auth.uid()) = owner_id );

-- Super admins can view all parties
create policy "Super admins can view all parties"
  on public.parties
  for select
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid())
        and is_super_admin = true
    )
  );

-- Grant access to authenticated role
grant select, insert, update, delete on public.parties to authenticated;


-- ─── 3. ledger_entries table ──────────────────────────────────────────────────
-- Each row is a single You Gave / You Got transaction for a party.
-- balance_after stores the running balance after this entry (denormalized
-- for fast display — avoids summing all entries on every read).
create table if not exists public.ledger_entries (
  id           uuid primary key default gen_random_uuid(),
  party_id     uuid not null references public.parties(id) on delete cascade,
  owner_id     uuid not null references auth.users(id) on delete cascade,
  entry_type   text not null check (entry_type in ('you_got', 'you_gave')),
  amount       numeric(14, 2) not null check (amount > 0),
  note         text,
  items        jsonb not null default '[]'::jsonb,
  -- items: [{ "stock_item_id": uuid|null, "name": str, "quantity": num, "rate": num|null }]
  balance_after numeric(14, 2) not null default 0.00,
  created_at   timestamptz not null default now()
);

-- Index for fast ledger fetch per party (newest first)
create index if not exists idx_ledger_entries_party_id
  on public.ledger_entries (party_id, created_at desc);

-- Index by owner for global queries
create index if not exists idx_ledger_entries_owner_id
  on public.ledger_entries (owner_id);

-- ─── 4. Enable RLS on ledger_entries ─────────────────────────────────────────
alter table public.ledger_entries enable row level security;

create policy "Users can view own ledger entries"
  on public.ledger_entries
  for select
  to authenticated
  using ( (select auth.uid()) = owner_id );

create policy "Users can insert own ledger entries"
  on public.ledger_entries
  for insert
  to authenticated
  with check ( (select auth.uid()) = owner_id );

create policy "Users can update own ledger entries"
  on public.ledger_entries
  for update
  to authenticated
  using ( (select auth.uid()) = owner_id )
  with check ( (select auth.uid()) = owner_id );

create policy "Users can delete own ledger entries"
  on public.ledger_entries
  for delete
  to authenticated
  using ( (select auth.uid()) = owner_id );

-- Super admins can view all ledger entries
create policy "Super admins can view all ledger entries"
  on public.ledger_entries
  for select
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid())
        and is_super_admin = true
    )
  );

grant select, insert, update, delete on public.ledger_entries to authenticated;


-- ─── 5. bank_accounts table ───────────────────────────────────────────────────
-- Stores bank accounts linked to the business user (Party → Banks tab).
create table if not exists public.bank_accounts (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null references auth.users(id) on delete cascade,
  bank_name      text not null,
  account_title  text not null,
  account_number text not null,
  created_at     timestamptz not null default now()
);

-- Index for fast lookup by owner
create index if not exists idx_bank_accounts_owner_id
  on public.bank_accounts (owner_id);

-- ─── 6. Enable RLS on bank_accounts ──────────────────────────────────────────
alter table public.bank_accounts enable row level security;

create policy "Users can view own bank accounts"
  on public.bank_accounts
  for select
  to authenticated
  using ( (select auth.uid()) = owner_id );

create policy "Users can insert own bank accounts"
  on public.bank_accounts
  for insert
  to authenticated
  with check ( (select auth.uid()) = owner_id );

create policy "Users can update own bank accounts"
  on public.bank_accounts
  for update
  to authenticated
  using ( (select auth.uid()) = owner_id )
  with check ( (select auth.uid()) = owner_id );

create policy "Users can delete own bank accounts"
  on public.bank_accounts
  for delete
  to authenticated
  using ( (select auth.uid()) = owner_id );

-- Super admins can view all bank accounts
create policy "Super admins can view all bank accounts"
  on public.bank_accounts
  for select
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid())
        and is_super_admin = true
    )
  );

grant select, insert, update, delete on public.bank_accounts to authenticated;


-- ─── 7. Auto-update updated_at on parties ────────────────────────────────────
-- Trigger function to keep updated_at fresh on row changes.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- Apply trigger to parties table
drop trigger if exists parties_set_updated_at on public.parties;
create trigger parties_set_updated_at
  before update on public.parties
  for each row execute function public.set_updated_at();

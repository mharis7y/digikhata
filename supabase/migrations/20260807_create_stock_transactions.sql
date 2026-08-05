-- ============================================================
-- DigiKhata Clone — Stock Transactions Module
-- Run this in Supabase Dashboard → SQL Editor
-- After: 20260806_create_khatabooks_module.sql
-- ============================================================

-- ─── 1. stock_transactions table ───────────────────────────────────────────
create table if not exists public.stock_transactions (
  id                  uuid primary key default gen_random_uuid(),
  owner_id            uuid not null references auth.users(id) on delete cascade,
  stock_item_id       uuid not null references public.stock_items(id) on delete cascade,
  transaction_type    text not null check (transaction_type in ('in', 'out')),
  quantity            numeric(14, 2) not null,
  rate                numeric(14, 2) not null,
  amount              numeric(14, 2) not null,
  details             text,
  party_id            uuid references public.parties(id) on delete set null,
  bill_no             text,
  created_at          timestamptz not null default now()
);

create index if not exists idx_stock_transactions_owner_id on public.stock_transactions (owner_id);
create index if not exists idx_stock_transactions_item_id on public.stock_transactions (stock_item_id);

alter table public.stock_transactions enable row level security;

create policy "Users can view own stock transactions" on public.stock_transactions for select to authenticated using ((select auth.uid()) = owner_id);
create policy "Users can insert own stock transactions" on public.stock_transactions for insert to authenticated with check ((select auth.uid()) = owner_id);
create policy "Users can update own stock transactions" on public.stock_transactions for update to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "Users can delete own stock transactions" on public.stock_transactions for delete to authenticated using ((select auth.uid()) = owner_id);

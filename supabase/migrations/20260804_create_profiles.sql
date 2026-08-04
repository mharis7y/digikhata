-- ============================================================
-- DigiKhata Clone — profiles table
-- Run this in Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. Create profiles table (linked to auth.users via id)
create table if not exists public.profiles (
  id                        uuid primary key references auth.users(id) on delete cascade,
  email                     text,
  display_name              text,
  avatar_url                text,

  -- KYC / Personal captures
  selfie_url                text,
  cnic_front_url            text,
  cnic_back_url             text,

  -- Business
  is_not_business_person    boolean not null default false,
  business_name             text,
  business_type             text,
  business_category         text,

  -- Status flags
  is_profile_setup_complete boolean not null default false,
  is_super_admin            boolean not null default false,

  -- Timestamps
  created_at                timestamptz not null default now(),
  updated_at                timestamptz not null default now()
);

-- 2. Enable Row Level Security (required per Supabase skill)
alter table public.profiles enable row level security;

-- 3. RLS Policies
-- Users can read their own profile
create policy "Users can view own profile"
  on public.profiles
  for select
  to authenticated
  using ( (select auth.uid()) = id );

-- Users can insert their own profile (first-time setup)
create policy "Users can insert own profile"
  on public.profiles
  for insert
  to authenticated
  with check ( (select auth.uid()) = id );

-- Users can update their own profile
create policy "Users can update own profile"
  on public.profiles
  for update
  to authenticated
  using ( (select auth.uid()) = id )
  with check ( (select auth.uid()) = id );

-- Super admins can view all profiles
create policy "Super admins can view all profiles"
  on public.profiles
  for select
  to authenticated
  using ( is_super_admin = true );

-- 4. Auto-populate email from auth.users when a new user signs up
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  insert into public.profiles (id, email, created_at, updated_at)
  values (
    new.id,
    new.email,
    now(),
    now()
  )
  on conflict (id) do update
    set email = excluded.email,
        updated_at = now();
  return new;
end;
$$;

-- Trigger fires after every new user creation in auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 5. Grant access to authenticated role (exposes table via Data API)
grant select, insert, update on public.profiles to authenticated;

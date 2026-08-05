-- ============================================================
-- Add bill_no to bills table
-- ============================================================

alter table public.bills 
add column if not exists bill_no text;

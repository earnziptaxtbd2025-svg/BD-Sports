-- =====================================================================
-- Step 1.1: profiles (name, division, role, photo) and profile photo storage.
-- Run this once in Supabase: SQL Editor > New query > paste all > Run.
-- Safe to run again: every statement checks if it already exists.
-- =====================================================================

-- ---- Table ----------------------------------------------------------
create table if not exists public.profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  phone         text,
  display_name  text not null default '' check (char_length(display_name) <= 60),
  division      text check (division in (
                  'dhaka', 'chattogram', 'rajshahi', 'khulna',
                  'barishal', 'sylhet', 'rangpur', 'mymensingh')),
  sports_role   text not null default 'fan'
                  check (sports_role in ('fan', 'organizer', 'player')),
  -- Permissions. A person can NOT change these two themselves (see trigger below).
  account_role  text not null default 'member'
                  check (account_role in ('member', 'moderator', 'super_admin')),
  is_suspended  boolean not null default false,
  photo_url     text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ---- Row Level Security ---------------------------------------------
-- Nobody can read or write a row unless a policy below allows it.
alter table public.profiles enable row level security;

drop policy if exists "profiles: read own" on public.profiles;
create policy "profiles: read own"
  on public.profiles for select
  to authenticated
  using (id = auth.uid());

-- A person can create only their own row, and only as an ordinary member.
drop policy if exists "profiles: create own" on public.profiles;
create policy "profiles: create own"
  on public.profiles for insert
  to authenticated
  with check (
    id = auth.uid()
    and account_role = 'member'
    and is_suspended = false
  );

drop policy if exists "profiles: update own" on public.profiles;
create policy "profiles: update own"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- ---- Protect role and suspension ------------------------------------
-- When a signed-in person updates their row, account_role and is_suspended always
-- keep the old value. Only the database owner (SQL Editor, service key) can change
-- them, because there auth.uid() is empty.
create or replace function public.protect_profile_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is not null then
    new.account_role := old.account_role;
    new.is_suspended := old.is_suspended;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists profiles_protect_columns on public.profiles;
create trigger profiles_protect_columns
  before update on public.profiles
  for each row execute function public.protect_profile_columns();

-- ---- Profile photos (storage) ---------------------------------------
-- Public bucket "avatars", max 512 KB per file, JPEG or PNG only. Each person can
-- write only inside the folder named with their own user id.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', true, 524288, array['image/jpeg', 'image/png'])
on conflict (id) do nothing;

drop policy if exists "avatars: anyone can view" on storage.objects;
create policy "avatars: anyone can view"
  on storage.objects for select
  using (bucket_id = 'avatars');

drop policy if exists "avatars: upload own" on storage.objects;
create policy "avatars: upload own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "avatars: replace own" on storage.objects;
create policy "avatars: replace own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "avatars: delete own" on storage.objects;
create policy "avatars: delete own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

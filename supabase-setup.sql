create table if not exists public.enquiries (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 120),
  email text not null check (char_length(email) between 3 and 320),
  subject text not null check (char_length(subject) between 1 and 200),
  message text not null check (char_length(message) between 1 and 10000),
  status text not null default 'new' check (status in ('new', 'in_progress', 'completed')),
  created_at timestamptz not null default now()
);

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);

alter table public.enquiries enable row level security;
alter table public.admin_users enable row level security;

revoke all on public.enquiries from anon, authenticated;
revoke all on public.admin_users from anon, authenticated;
grant insert on public.enquiries to anon, authenticated;
grant select, update on public.enquiries to authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.admin_users
    where user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

drop policy if exists "Anyone can submit enquiries" on public.enquiries;
create policy "Anyone can submit enquiries"
  on public.enquiries for insert to anon, authenticated
  with check (status = 'new');

drop policy if exists "Admins can read enquiries" on public.enquiries;
create policy "Admins can read enquiries"
  on public.enquiries for select to authenticated
  using ((select public.is_admin()));

drop policy if exists "Admins can update enquiries" on public.enquiries;
create policy "Admins can update enquiries"
  on public.enquiries for update to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

-- Website images are stored in a public Supabase Storage bucket named "website-images".
-- Create the bucket in Supabase Storage before applying these policies.
drop policy if exists "Public website images are visible" on storage.objects;
create policy "Public website images are visible"
  on storage.objects for select
  using (bucket_id = 'website-images');

drop policy if exists "Admins can upload website images" on storage.objects;
create policy "Admins can upload website images"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'website-images'
    and (select public.is_admin())
  );

drop policy if exists "Admins can delete website images" on storage.objects;
create policy "Admins can delete website images"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'website-images'
    and (select public.is_admin())
  );
  
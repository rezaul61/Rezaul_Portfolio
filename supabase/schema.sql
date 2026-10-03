-- Run this ONCE in Supabase -> SQL Editor -> New query -> Run.

-- 1) Tables
create table if not exists public.portfolio (
  id int primary key default 1 check (id = 1),
  content jsonb not null,
  updated_at timestamptz not null default now(ac)
);
create table if not exists public.messages (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) between 1 and 120),
  email text not null check (char_length(email) between 3 and 200),
  subject text not null check (char_length(subject) between 1 and 200),
  message text not null check (char_length(message) between 1 and 5000),
  created_at timestamptz not null default now()
);
create table if not exists public.visits (
  vid text not null check (char_length(vid) <= 64),
  day date not null default current_date,
  primary key (vid, day)
);
create table if not exists public.admins (user_id uuid primary key references auth.users on delete cascade);

-- 2) Who is admin
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as
$$ select exists (select 1 from public.admins where user_id = auth.uid()) $$;

-- 3) Visit counter (visitors can only call this function, never read/write the table)
create or replace function public.log_visit(p_vid text) returns bigint
language plpgsql security definer set search_path = public as $$
begin
  if p_vid is not null and char_length(p_vid) <= 64 then
    insert into public.visits(vid) values (p_vid) on conflict do nothing;
  end if;
  return (select count(*) from public.visits);
end $$;
grant execute on function public.log_visit(text) to anon, authenticated;
grant execute on function public.is_admin() to anon, authenticated;

-- 4) Row Level Security: visitors read-only, admin writes
alter table public.portfolio enable row level security;
alter table public.messages  enable row level security;
alter table public.visits    enable row level security;
alter table public.admins    enable row level security;

create policy "anyone can read portfolio" on public.portfolio for select using (true);
create policy "admin writes portfolio" on public.portfolio for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "anyone can send a message" on public.messages for insert to anon, authenticated with check (true);
create policy "admin reads messages" on public.messages for select to authenticated using (public.is_admin());
create policy "admin deletes messages" on public.messages for delete to authenticated using (public.is_admin());

-- 5) File storage (profile photo, project/certificate photos, CV)
insert into storage.buckets (id, name, public) values ('media', 'media', true) on conflict (id) do nothing;
create policy "admin uploads media" on storage.objects for insert to authenticated
  with check (bucket_id = 'media' and public.is_admin());
create policy "admin updates media" on storage.objects for update to authenticated
  using (bucket_id = 'media' and public.is_admin());
create policy "admin deletes media" on storage.objects for delete to authenticated
  using (bucket_id = 'media' and public.is_admin());

-- 6) Live updates for open public pages
alter publication supabase_realtime add table public.portfolio;

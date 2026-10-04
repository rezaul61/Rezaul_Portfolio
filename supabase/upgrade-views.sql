-- Run ONCE in Supabase -> SQL Editor -> New query -> Run.
-- Adds an accurate, live "Profile Visits" counter (safe to run more than once).

create table if not exists public.site_stats (
  id int primary key default 1 check (id = 1),
  views bigint not null default 0
);
-- keep your existing history: start from the number of old unique visits
insert into public.site_stats(id, views)
  select 1, (select count(*) from public.visits)
  on conflict (id) do nothing;

alter table public.site_stats enable row level security;
drop policy if exists "anyone can read stats" on public.site_stats;
create policy "anyone can read stats" on public.site_stats for select using (true);

-- +1 view (the page calls this once per browser session) and returns the new total
create or replace function public.log_view(p_vid text) returns bigint
language plpgsql security definer set search_path = public as $$
declare total bigint;
begin
  if p_vid is not null and char_length(p_vid) <= 64 then
    insert into public.visits(vid) values (p_vid) on conflict do nothing; -- unique visitors/day (kept)
  end if;
  update public.site_stats set views = views + 1 where id = 1 returning views into total;
  return total;
end $$;

create or replace function public.get_views() returns bigint
language sql stable security definer set search_path = public as
$$ select views from public.site_stats where id = 1 $$;

grant execute on function public.log_view(text) to anon, authenticated;
grant execute on function public.get_views() to anon, authenticated;

-- push every change to all open pages in real time
do $$ begin
  alter publication supabase_realtime add table public.site_stats;
exception when duplicate_object then null; end $$;

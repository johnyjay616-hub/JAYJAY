create extension if not exists "uuid-ossp";
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 username text unique not null, full_name text not null, avatar_url text, cover_url text,
 bio text default '', country text, interests text[] default '{}', birth_date date,
 created_at timestamptz default now()
);
create table if not exists public.posts (
 id uuid primary key default uuid_generate_v4(), user_id uuid not null references public.profiles(id) on delete cascade,
 content text default '', image_url text, created_at timestamptz default now()
);
create table if not exists public.likes (
 post_id uuid references public.posts(id) on delete cascade, user_id uuid references public.profiles(id) on delete cascade,
 created_at timestamptz default now(), primary key(post_id,user_id)
);
create table if not exists public.comments (
 id uuid primary key default uuid_generate_v4(), post_id uuid references public.posts(id) on delete cascade,
 user_id uuid references public.profiles(id) on delete cascade, content text not null, created_at timestamptz default now()
);
create table if not exists public.friendships (
 id uuid primary key default uuid_generate_v4(), requester_id uuid references public.profiles(id) on delete cascade,
 addressee_id uuid references public.profiles(id) on delete cascade,
 status text not null default 'pending' check(status in ('pending','accepted','declined')),
 created_at timestamptz default now(), unique(requester_id,addressee_id)
);
create table if not exists public.messages (
 id uuid primary key default uuid_generate_v4(), sender_id uuid references public.profiles(id) on delete cascade,
 receiver_id uuid references public.profiles(id) on delete cascade, content text not null,
 created_at timestamptz default now(), read_at timestamptz
);
create table if not exists public.notifications (
 id uuid primary key default uuid_generate_v4(), user_id uuid references public.profiles(id) on delete cascade,
 actor_id uuid references public.profiles(id) on delete cascade, type text not null, entity_id uuid,
 message text, read boolean default false, created_at timestamptz default now()
);
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.likes enable row level security;
alter table public.comments enable row level security;
alter table public.friendships enable row level security;
alter table public.messages enable row level security;
alter table public.notifications enable row level security;
create policy "profiles readable" on public.profiles for select using (true);
create policy "users create own profile" on public.profiles for insert with check (auth.uid()=id);
create policy "users update own profile" on public.profiles for update using (auth.uid()=id);
create policy "posts readable" on public.posts for select using (true);
create policy "users create posts" on public.posts for insert with check (auth.uid()=user_id);
create policy "users update own posts" on public.posts for update using (auth.uid()=user_id);
create policy "users delete own posts" on public.posts for delete using (auth.uid()=user_id);
create policy "likes readable" on public.likes for select using (true);
create policy "users manage own likes" on public.likes for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
create policy "comments readable" on public.comments for select using (true);
create policy "users create comments" on public.comments for insert with check (auth.uid()=user_id);
create policy "users manage own comments" on public.comments for update using (auth.uid()=user_id);
create policy "friendships participants readable" on public.friendships for select using (auth.uid()=requester_id or auth.uid()=addressee_id);
create policy "users send requests" on public.friendships for insert with check (auth.uid()=requester_id);
create policy "participants update requests" on public.friendships for update using (auth.uid()=requester_id or auth.uid()=addressee_id);
create policy "participants delete requests" on public.friendships for delete using (auth.uid()=requester_id or auth.uid()=addressee_id);
create policy "participants read messages" on public.messages for select using (auth.uid()=sender_id or auth.uid()=receiver_id);
create policy "users send messages" on public.messages for insert with check (auth.uid()=sender_id);
create policy "participants update messages" on public.messages for update using (auth.uid()=sender_id or auth.uid()=receiver_id);
create policy "users read notifications" on public.notifications for select using (auth.uid()=user_id);
create policy "users update notifications" on public.notifications for update using (auth.uid()=user_id);
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
 insert into public.profiles(id,username,full_name)
 values(new.id,coalesce(new.raw_user_meta_data->>'username','user_'||substr(new.id::text,1,8)),coalesce(new.raw_user_meta_data->>'full_name','New ConnectWorld User'))
 on conflict (id) do nothing;
 return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.notifications;
alter publication supabase_realtime add table public.posts;
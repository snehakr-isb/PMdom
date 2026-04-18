-- PM Daily Questions — Supabase Schema

create table if not exists questions (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('multipleChoice','fillInBlank','scenario','matching','trueFalse','ordering')),
  category text not null check (category in ('interviewPrep','pmFrameworks','aiTechFundamentals','currentEvents')),
  difficulty text not null check (difficulty in ('beginner','intermediate','advanced')),
  prompt text not null,
  content jsonb not null,
  explanation text not null,
  tags text[] default '{}',
  xp_value int not null default 10,
  estimated_seconds int not null default 30,
  published_date date not null default current_date,
  version int not null default 1,
  created_at timestamptz not null default now()
);

create index questions_category_idx on questions(category);
create index questions_published_date_idx on questions(published_date desc);
create index questions_difficulty_idx on questions(difficulty);

-- Enable row level security (read-only for anon)
alter table questions enable row level security;
create policy "Public read" on questions for select using (true);

-- Weekly scores for leaderboard (Phase 2)
create table if not exists weekly_scores (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  display_name text not null,
  weekly_xp int not null default 0,
  iso_week int not null,
  iso_year int not null,
  created_at timestamptz not null default now(),
  unique(user_id, iso_week, iso_year)
);

alter table weekly_scores enable row level security;
create policy "Users read own scores" on weekly_scores for select using (true);
create policy "Users insert own scores" on weekly_scores for insert with check (true);
create policy "Users update own scores" on weekly_scores for update using (true);

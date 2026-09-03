create table items (
  id integer primary key,
  name text not null,
  created_at real not null default (unixepoch('now', 'subsec'))
);

-- create the import scheama to keep the raw date from the public schema
create schema if not exists import;

-- drop tables now 
drop table if exists events cascade;
drop table if exists teams cascade;
drop table if exists targets cascade;
drop table if exists spass_types cascade;
drop table if exists requests cascade;
drop table if exists event_types cascade;

-- import the raw data
drop table if exists import.master_plan;
create table import.master_plan(
  start_time_utc text,
  duration text,
  date text,
  team text,
  spass_type text,
  target text,
  request_name text,
  library_definition text,
  title text,
  description text
); 
COPY import.master_plan FROM '/mnt/common/workspace/enceladus/master_plan/data/master_plan.csv' WITH DELIMITER ',' HEADER CSV;
-- lookup tables

-- teams
drop table if exists teams;
select distinct(team)
as description
into teams
from import.master_plan;

alter table teams
add id serial primary key;

-- spass types
drop table if exists spass_types;
select distinct(spass_type)
as description
into spass_types
from import.master_plan;

alter table spass_types
add id serial primary key;

-- target
drop table if exists targets;
select distinct(target)
as description
into targets
from import.master_plan;


alter table targets
add id serial primary key;

-- event types
drop table if exists event_types;
select distinct(library_definition)
as description
into event_types
from import.master_plan;


alter table event_types
add id serial primary key;

-- requests
drop table if exists requests;
select distinct(request_name)
as description
into requests
from import.master_plan;

alter table requests
add id serial primary key;

-- public event fact table
drop table if exists events;
create table events(
  id serial primary key,
  time_stamp timestamptz not null,
  title varchar(500),
  description text,
  event_type_id int references event_types(id),
  target_id int references targets(id),
  team_id int references teams(id),
  request_id int references requests(id),
  spass_type_id int references spass_types(id)
);

insert into events(
  time_stamp,
  title,
  description,
  event_type_id,
  target_id,
  team_id,
  request_id,
  spass_type_id
)
select
  import.master_plan.start_time_utc::timestamp,
  import.master_plan.title,
  import.master_plan.description,
  event_types.id as event_type_id,
  targets.id as target_id,
  teams.id as team_id,
  requests.id as request_id,
  spass_types.id as spass_type_id
from
  import.master_plan
  inner join event_types
    on event_types.description = import.master_plan.library_definition
  left join targets
    on targets.description = import.master_plan.target
  left join teams
    on teams.description = import.master_plan.team
  left join requests
    on requests.description = import.master_plan.request_name
  left join spass_types
    on spass_types.description = import.master_plan.spass_type;

-- create a view on the event data just for the enceladus data
drop view if exists enceladus_events;
create materialized view enceladus_events as
select
  events.id,
  events.title,
  events.description,
  events.time_stamp,
  events.time_stamp::date as date,
  event_types.description as event,
  to_tsvector(concat(events.description, '', events.title)) as search
from events
inner join event_types 
  on event_types.id = events.event_type_id
where target_id = 40
order by time_stamp;

create index idx_event_search on enceladus_events using GIN(search);

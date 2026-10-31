-- =====================================================================
-- Agriculture Information System  -  reports.sql
-- Run AFTER schema.sql.
--
-- Every report is a SQL function so the date range (and other filters)
-- can be passed as parameters. The app calls them with:
--     supabase.rpc('rpt_harvest_per_crop', { p_from: '2026-01-01', p_to: null })
-- A NULL parameter means "no limit".
--
-- The functions are SECURITY INVOKER (the default), so Row Level Security
-- still applies to whoever runs them. Nothing here is hard-coded data.
-- =====================================================================


-- ---------------------------------------------------------------------
-- DASHBOARD: one row of totals for the summary cards
-- ---------------------------------------------------------------------
create function dashboard_totals()
returns table (
  total_farmers   bigint,
  total_farms     bigint,
  total_crops     bigint,
  total_plantings bigint,
  total_harvests  bigint,
  total_hectares  numeric,
  total_harvest_kg numeric,
  estimated_harvest_value numeric,
  total_revenue   numeric
)
language sql stable set search_path = public as $$
  select
    (select count(*) from farmer),
    (select count(*) from farm),
    (select count(*) from crop),
    (select count(*) from planting),
    (select count(*) from harvest),
    (select coalesce(sum(area_hectares), 0) from farm),
    (select coalesce(sum(quantity_kg), 0) from harvest),
    (select coalesce(round(sum(quantity_kg * selling_price_per_kg), 2), 0) from harvest),
    (select coalesce(round(sum(quantity_kg * price_per_kg), 2), 0) from sale);
$$;


-- ---------------------------------------------------------------------
-- R1. Farmers and their farms   (date filter: date_registered)
-- ---------------------------------------------------------------------
create function rpt_farmers_farms(p_from date default null, p_to date default null)
returns table (
  farmer_id integer, farmer_name text, contact_number text, address text,
  date_registered date, farm_name text, location text, area_hectares numeric,
  soil_type text, irrigation_type text
)
language sql stable set search_path = public as $$
  select fr.farmer_id,
         (fr.last_name || ', ' || fr.first_name)::text,
         fr.contact_number::text,
         fr.address::text,
         fr.date_registered,
         coalesce(fm.farm_name, '(no farm yet)')::text,
         fm.location::text,
         fm.area_hectares,
         st.soil_type_name::text,
         it.irrigation_type_name::text
  from farmer fr
  left join farm            fm on fm.farmer_id          = fr.farmer_id
  left join soil_type       st on st.soil_type_id       = fm.soil_type_id
  left join irrigation_type it on it.irrigation_type_id = fm.irrigation_type_id
  where (p_from is null or fr.date_registered >= p_from)
    and (p_to   is null or fr.date_registered <= p_to)
  order by fr.last_name, fr.first_name, fm.farm_name;
$$;


-- ---------------------------------------------------------------------
-- R2. Crops planted per farm   (date filter: planting_date)
-- ---------------------------------------------------------------------
create function rpt_crops_per_farm(p_from date default null, p_to date default null)
returns table (
  farm_name text, farmer_name text, crop_name text, variety text,
  planting_count bigint, total_area_planted numeric, total_seed_quantity numeric,
  first_planting date, last_planting date
)
language sql stable set search_path = public as $$
  select fm.farm_name::text,
         (fr.first_name || ' ' || fr.last_name)::text,
         c.crop_name::text,
         c.variety::text,
         count(*),
         sum(p.area_planted),
         sum(p.seed_quantity),
         min(p.planting_date),
         max(p.planting_date)
  from planting p
  join farm   fm on fm.farm_id   = p.farm_id
  join farmer fr on fr.farmer_id = fm.farmer_id
  join crop   c  on c.crop_id    = p.crop_id
  where (p_from is null or p.planting_date >= p_from)
    and (p_to   is null or p.planting_date <= p_to)
  group by fm.farm_id, fm.farm_name, fr.first_name, fr.last_name, c.crop_id, c.crop_name, c.variety
  order by fm.farm_name, c.crop_name;
$$;


-- ---------------------------------------------------------------------
-- R3. Planting summary by status   (also used by the dashboard chart)
--     Statuses with zero plantings are still listed.
-- ---------------------------------------------------------------------
create function rpt_planting_status_summary(p_from date default null, p_to date default null)
returns table (status_id smallint, status_name text, planting_count bigint, total_area_planted numeric)
language sql stable set search_path = public as $$
  select ps.status_id,
         ps.status_name::text,
         count(p.planting_id),
         coalesce(sum(p.area_planted), 0)
  from planting_status ps
  left join planting p
         on p.status_id = ps.status_id
        and (p_from is null or p.planting_date >= p_from)
        and (p_to   is null or p.planting_date <= p_to)
  group by ps.status_id, ps.status_name
  order by ps.status_id;
$$;


-- ---------------------------------------------------------------------
-- R4. Planting records by status (detail)   optional status filter
-- ---------------------------------------------------------------------
create function rpt_planting_by_status(p_from date default null, p_to date default null, p_status_id smallint default null)
returns table (
  status_name text, planting_id integer, farm_name text, crop_name text,
  planting_date date, expected_harvest_date date, area_planted numeric, seed_quantity numeric
)
language sql stable set search_path = public as $$
  select ps.status_name::text, p.planting_id, fm.farm_name::text,
         (c.crop_name || ' (' || c.variety || ')')::text,
         p.planting_date, p.expected_harvest_date, p.area_planted, p.seed_quantity
  from planting p
  join planting_status ps on ps.status_id = p.status_id
  join farm            fm on fm.farm_id   = p.farm_id
  join crop            c  on c.crop_id    = p.crop_id
  where (p_from      is null or p.planting_date >= p_from)
    and (p_to        is null or p.planting_date <= p_to)
    and (p_status_id is null or p.status_id = p_status_id)
  order by ps.status_id, p.planting_date;
$$;


-- ---------------------------------------------------------------------
-- R5. Harvest records with estimated value   optional grade filter
-- ---------------------------------------------------------------------
create function rpt_harvest_records(p_from date default null, p_to date default null, p_grade_id smallint default null)
returns table (
  harvest_id integer, harvest_date date, farm_name text, crop_name text,
  quantity_kg numeric, selling_price_per_kg numeric, estimated_value numeric,
  grade_name text, remark_description text
)
language sql stable set search_path = public as $$
  select h.harvest_id, h.harvest_date, fm.farm_name::text,
         (c.crop_name || ' (' || c.variety || ')')::text,
         h.quantity_kg, h.selling_price_per_kg,
         round(h.quantity_kg * h.selling_price_per_kg, 2),
         qg.grade_name::text, hr.remark_description::text
  from harvest h
  join planting       p  on p.planting_id = h.planting_id
  join farm           fm on fm.farm_id    = p.farm_id
  join crop           c  on c.crop_id     = p.crop_id
  join quality_grade  qg on qg.grade_id   = h.grade_id
  join harvest_remark hr on hr.remark_id  = h.remark_id
  where (p_from     is null or h.harvest_date >= p_from)
    and (p_to       is null or h.harvest_date <= p_to)
    and (p_grade_id is null or h.grade_id = p_grade_id)
  order by h.harvest_date desc;
$$;


-- ---------------------------------------------------------------------
-- R6. Total harvest per crop: quantity + estimated value
--     (covers "total harvested quantity" and "estimated harvest value")
-- ---------------------------------------------------------------------
create function rpt_harvest_per_crop(p_from date default null, p_to date default null)
returns table (
  crop_name text, harvest_count bigint, total_quantity_kg numeric,
  avg_price_per_kg numeric, estimated_value numeric
)
language sql stable set search_path = public as $$
  select (c.crop_name || ' (' || c.variety || ')')::text,
         count(*),
         sum(h.quantity_kg),
         round(avg(h.selling_price_per_kg), 2),
         round(sum(h.quantity_kg * h.selling_price_per_kg), 2)
  from harvest h
  join planting p on p.planting_id = h.planting_id
  join crop     c on c.crop_id     = p.crop_id
  where (p_from is null or h.harvest_date >= p_from)
    and (p_to   is null or h.harvest_date <= p_to)
  group by c.crop_id, c.crop_name, c.variety
  order by 3 desc;
$$;


-- ---------------------------------------------------------------------
-- R7. Total harvest per season
--     Season is taken from the HARVEST month using the Philippine
--     climate pattern: Wet Season = June-November, Dry Season = December-May.
--     A December harvest belongs to the dry season of the following year
--     (e.g. Dec 2026 -> Dry Season 2027).
-- ---------------------------------------------------------------------
create function rpt_harvest_per_season(p_from date default null, p_to date default null)
returns table (
  season_label text, crop_name text, harvest_count bigint,
  total_quantity_kg numeric, estimated_value numeric
)
language sql stable set search_path = public as $$
  with h as (
    select h.*,
           case when extract(month from h.harvest_date) between 6 and 11
                then 'Wet Season ' || extract(year from h.harvest_date)
                else 'Dry Season ' || extract(year from h.harvest_date + interval '1 month')
           end as season_label,
           -- sort key: first day of that season
           case when extract(month from h.harvest_date) between 6 and 11
                then make_date(extract(year from h.harvest_date)::int, 6, 1)
                else make_date(extract(year from h.harvest_date + interval '1 month')::int - 1, 12, 1)
           end as season_start
    from harvest h
    where (p_from is null or h.harvest_date >= p_from)
      and (p_to   is null or h.harvest_date <= p_to)
  )
  select h.season_label::text,
         c.crop_name::text,
         count(*),
         sum(h.quantity_kg),
         round(sum(h.quantity_kg * h.selling_price_per_kg), 2)
  from h
  join planting p on p.planting_id = h.planting_id
  join crop     c on c.crop_id     = p.crop_id
  group by h.season_start, h.season_label, c.crop_name
  order by h.season_start, 4 desc;
$$;


-- ---------------------------------------------------------------------
-- R8. Farmer production summary   (date filter: harvest_date / sale_date)
--     Sub-queries are used so that joining farms, harvests and sales does
--     not multiply rows and inflate the totals.
-- ---------------------------------------------------------------------
create function rpt_farmer_production(p_from date default null, p_to date default null)
returns table (
  farmer_name text, farm_count bigint, total_hectares numeric, planting_count bigint,
  harvest_count bigint, total_harvest_kg numeric, estimated_value numeric, sales_revenue numeric
)
language sql stable set search_path = public as $$
  select (fr.last_name || ', ' || fr.first_name)::text,
         (select count(*) from farm fm where fm.farmer_id = fr.farmer_id),
         (select coalesce(sum(fm.area_hectares), 0) from farm fm where fm.farmer_id = fr.farmer_id),
         (select count(*) from planting p join farm fm on fm.farm_id = p.farm_id
           where fm.farmer_id = fr.farmer_id),
         hv.harvest_count,
         hv.total_kg,
         hv.est_value,
         (select coalesce(round(sum(s.quantity_kg * s.price_per_kg), 2), 0)
            from sale s
            join harvest  h  on h.harvest_id  = s.harvest_id
            join planting p  on p.planting_id = h.planting_id
            join farm     fm on fm.farm_id    = p.farm_id
           where fm.farmer_id = fr.farmer_id
             and (p_from is null or s.sale_date >= p_from)
             and (p_to   is null or s.sale_date <= p_to))
  from farmer fr
  cross join lateral (
    select count(h.harvest_id)                                         as harvest_count,
           coalesce(sum(h.quantity_kg), 0)                             as total_kg,
           coalesce(round(sum(h.quantity_kg * h.selling_price_per_kg), 2), 0) as est_value
    from harvest h
    join planting p  on p.planting_id = h.planting_id
    join farm     fm on fm.farm_id    = p.farm_id
    where fm.farmer_id = fr.farmer_id
      and (p_from is null or h.harvest_date >= p_from)
      and (p_to   is null or h.harvest_date <= p_to)
  ) hv
  order by hv.total_kg desc, fr.last_name;
$$;


-- ---------------------------------------------------------------------
-- R9. Sales and revenue per period   p_period = 'month' | 'quarter' | 'year'
--     (also used by the dashboard "monthly sales trend" chart)
--     Periods with no sales are listed with 0, so a trend chart does not
--     hide the gap.
-- ---------------------------------------------------------------------
create function rpt_sales_per_period(p_from date default null, p_to date default null, p_period text default 'month')
returns table (
  period_start date, period_label text, sale_count bigint,
  quantity_kg numeric, revenue numeric
)
language sql stable set search_path = public as $$
  with params as (
    select case when p_period in ('month', 'quarter', 'year') then p_period else 'month' end as unit
  ),
  s as (
    select s.*, date_trunc((select unit from params), s.sale_date)::date as period_start
    from sale s
    where (p_from is null or s.sale_date >= p_from)
      and (p_to   is null or s.sale_date <= p_to)
  ),
  periods as (      -- every period from the first to the last sale
    select generate_series(min(period_start), max(period_start),
                           case (select unit from params)
                             when 'quarter' then interval '3 months'
                             when 'year'    then interval '1 year'
                             else                interval '1 month'
                           end)::date as period_start
    from s
  )
  select pr.period_start,
         case (select unit from params)
           when 'year'    then to_char(pr.period_start, 'YYYY')
           when 'quarter' then to_char(pr.period_start, 'YYYY "Q"Q')
           else                to_char(pr.period_start, 'Mon YYYY')
         end,
         count(s.sale_id),
         coalesce(sum(s.quantity_kg), 0),
         coalesce(round(sum(s.quantity_kg * s.price_per_kg), 2), 0)
  from periods pr
  left join s on s.period_start = pr.period_start
  group by pr.period_start
  order by pr.period_start;
$$;


-- ---------------------------------------------------------------------
-- R10. Input / fertilizer usage per farm   (date filter: usage_date)
--      Cost uses the input's current unit cost.
-- ---------------------------------------------------------------------
create function rpt_input_usage_per_farm(p_from date default null, p_to date default null)
returns table (
  farm_name text, input_type text, input_name text, times_applied bigint,
  total_quantity numeric, unit text, estimated_cost numeric
)
language sql stable set search_path = public as $$
  select fm.farm_name::text,
         it.input_type_name::text,
         i.input_name::text,
         count(*),
         sum(iu.quantity),
         u.unit_code::text,
         round(sum(iu.quantity * i.unit_cost), 2)
  from input_usage iu
  join planting        p  on p.planting_id    = iu.planting_id
  join farm            fm on fm.farm_id       = p.farm_id
  join input_item      i  on i.input_id       = iu.input_id
  join input_type      it on it.input_type_id = i.input_type_id
  join unit_of_measure u  on u.unit_id        = i.unit_id
  where (p_from is null or iu.usage_date >= p_from)
    and (p_to   is null or iu.usage_date <= p_to)
  group by fm.farm_id, fm.farm_name, it.input_type_name, i.input_id, i.input_name, u.unit_code
  order by fm.farm_name, it.input_type_name, i.input_name;
$$;


-- ---------------------------------------------------------------------
-- R11. Production by location   (dashboard chart + report)
-- ---------------------------------------------------------------------
create function rpt_production_by_location(p_from date default null, p_to date default null)
returns table (location text, farm_count bigint, harvest_count bigint, total_quantity_kg numeric, estimated_value numeric)
language sql stable set search_path = public as $$
  select fm.location::text,
         count(distinct fm.farm_id),
         count(*),
         sum(h.quantity_kg),
         round(sum(h.quantity_kg * h.selling_price_per_kg), 2)
  from harvest h
  join planting p  on p.planting_id = h.planting_id
  join farm     fm on fm.farm_id    = p.farm_id
  where (p_from is null or h.harvest_date >= p_from)
    and (p_to   is null or h.harvest_date <= p_to)
  group by fm.location
  order by 4 desc;
$$;

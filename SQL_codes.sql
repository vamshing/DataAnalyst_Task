------------THE FINAL QUERY BUILD----------------------------------------------------------------------


select q.DiffDate,sum(q.is_active_wedding) as Active_weddings,
sum(q.is_successful_wedding) as Successful_weddings,
sum(q.is_viral_wedding) as Viral_weddings
from (select DATEDIFF(a.wedding_date,a.created_at) AS DiffDate,
b.wedding_id,

# ACTIVE WEDDING FLAG
(select CASE WHEN count(*) >= 20 THEN 1 ELSE 0 END AS count 
FROM wedpics_test.media c
where c.wedding_id = a.id 
and is_flagged = 0
and is_wedding_profile = 0
and is_user_profile = 0
and publish_step = 2
) as is_active_wedding,

# VIRAL WEDDING FLAG

(select case when sum((select count(*) from wedpics_test.users_weddings f
where f.is_admin = 'S'
and f.created_at > d.created_at 
and f.user_id = d.user_id
)) >= 1 then 1 else 0 end as cnt
from wedpics_test.users_weddings d
where (d.is_admin <> 'S' or d.is_admin is null)
and d.wedding_id = a.id
) as is_viral_wedding,


# SUCCESSFUL WEDDING FLAG
(select 
CASE 
WHEN 
count(*) >= 100 
and count(distinct date(d.created_at)) >= 3
and 
(select count(distinct e.user_id) from wedpics_test.users_weddings e where e.wedding_id = d.wedding_id)  >= 15
THEN 1 ELSE 0 END AS count 
FROM wedpics_test.media d
where  d.wedding_id = a.id
and d.is_flagged = 0
and d.is_wedding_profile = 0
and d.is_user_profile = 0
and d.publish_step = 2) as is_successful_wedding


from wedpics_test.weddings a
left join wedpics_test.users_weddings b 
on a.id = b.wedding_id
where 
date(a.wedding_date) between '2015-11-01' and '2015-12-31'
and a.payment = 1 
and a.is_deleted = 0
and b.is_admin = 'S'
ORDER BY is_viral_wedding desc
) as q
group by DiffDate
	
----------------------------------days vs total wedding numbers----------------------------

# we shall take the total wedding numbers in the period specified - Nov - Dec,2015

# CREATE tmp_overallweddings : the table for OVERALL WEDDING NUMBERS BY TIME-FRAME LOOKUP

create table tmp_overallweddings as (
select DATEDIFF(a.wedding_date,a.created_at) AS DiffDate,count(*) as num_weddings
from wedpics_test.weddings a
left join wedpics_test.users_weddings b 
on a.id = b.wedding_id
where 
date(a.wedding_date) between '2015-11-01' and '2015-12-31'
and a.payment = 1 
and a.is_deleted = 0
and b.is_admin = 'S'
group by DiffDate
order by num_weddings desc
)

select a.*,b.num_weddings from tmp_output a 
inner join tmp_overallweddings b on a.DiffDate = b.DiffDate

---------------------------------------------------------------------------------------------------------

select 
a.*,
round((a.Active_weddings/b.num_weddings) * 100,0) as Active_percent ,
round((a.Successful_weddings/b.num_weddings) * 100,0) as Successful_percent ,
round((a.Viral_weddings/b.num_weddings) * 100,0) as Viral_percent,
b.num_weddings

from tmp_output a 
inner join tmp_overallweddings b on a.DiffDate = b.DiffDate













---------------------------------------------------------------------------------------------------------------------------
# VIRAL WEDDING:

# defined as any member (admin or guest but not super admin) who creates a wedding after they become part of the wedding
# if a user was as Super admin before, and attended the any wedding later as guest/admin, he would not included for the viral wedding contribution.
# cnt - the number of weddings initiated by the user after attending the weddin as non super admin



select a.id,(select case when sum((select count(*) from wedpics_test.users_weddings f
where f.is_admin = 'S'
and f.created_at > d.created_at 
and f.user_id = d.user_id
)) >= 1 then 1 else 0 end as cnt
from wedpics_test.users_weddings d
where (d.is_admin <> 'S' or d.is_admin is null)
and d.wedding_id = a.id
) as cnt

from wedpics_test.weddings a
left join wedpics_test.users_weddings b on a.id = b.wedding_id
where 
date(a.wedding_date) between '2015-11-01' and '2015-12-31'
and a.payment = 1 
and a.is_deleted = 0
and b.is_admin = 'S'

group by id
order by cnt desc

	
-------------------
# SUCCESSFUL WEDDING:


select 
CASE 
WHEN 
count(*) >= 100 
and count(distinct date(d.created_at)) >= 3
and 
(select count(distinct e.user_id) from wedpics_test.users_weddings e where e.wedding_id = d.wedding_id)  >= 15
THEN 1 ELSE 0 END AS count 
FROM wedpics_test.media d
where  d.wedding_id = a.id
and d.is_flagged = 0
and d.is_wedding_profile = 0
and d.is_user_profile = 0
and d.publish_step = 2
1052015 967406 799138  - successful weddings


viral

817488
842338
915433
973292
977255
896968
985115


1083407



# selection of the weddings

select count(*) from wedpics_test.weddings 
where 
date(wedding_date) between '2015-11-01' 
and '2015-12-31'
and payment = 1 
and is_deleted = 0
and 
id in
(
select wedding_id from wedpics_test.users_weddings 
WHERE is_admin = 'S'
)

# 3902

select a.*,b.* from wedpics_test.weddings a
left join wedpics_test.users_weddings b on a.id = b.wedding_id
where 
date(a.wedding_date) between '2015-11-01' and '2015-12-31'
and a.payment = 1 
and a.is_deleted = 0
and b.is_admin = 'S'

# 3902
#




################################## THE ONLY TWO TABLES WHICH MATTER #########################


# media count
select * from wedpics_test.media 
where is_deleted = 0
and is_flagged = 0
and is_wedding_profile = 0
and is_user_profile = 0
and publish_step = 2


select DATEDIFF(a.wedding_date,a.created_at) AS DiffDate,
b.user_id AS super_admin_id,
b.wedding_id
from wedpics_test.weddings a
left join wedpics_test.users_weddings b 
on a.id = b.wedding_id
where 
date(a.wedding_date) between '2015-11-01' and '2015-12-31'
and a.payment = 1 
and a.is_deleted = 0
and b.is_admin = 'S'
















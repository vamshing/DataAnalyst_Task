
"""
#-----------------------------THE FINAL QUERY BUILD--------------------------------------------------------------

# TABLE : tmp_output          - stores the aggregated time-frame and along with viral,
                                successful,active wedding numbers
# TABLE : tmp_overallweddings - stores the aggregated time-frame of OVERALL wedding numbers
"""

query1 = """

# var : DiffDate            - The number of days between wedding created and the wedding date 
# col : Active_weddings     - Aggregated number of active wedding sin the given time frame
# col : Successful_weddings - Aggregated number of successful weddings in the given time frame
# col : Viral_weddings      - Aggregated number of viral weddings in the given time frame

create table tmp_output as (

select q.DiffDate,sum(q.is_active_wedding) as Active_weddings,
sum(q.is_successful_wedding) as Successful_weddings,
sum(q.is_viral_wedding) as Viral_weddings
from (

select DATEDIFF(a.wedding_date,a.created_at) AS DiffDate,
b.wedding_id,

# ACTIVE WEDDING FLAG(1=yes,0=no)

# var : is_active_wedding - flag to indicate the whether active wedding or not ( specific to the wedding_id)

(select CASE WHEN count(*) >= 20 THEN 1 ELSE 0 END AS count 
FROM wedpics_test.media c
where c.wedding_id = a.id 
and is_flagged = 0
and is_wedding_profile = 0
and is_user_profile = 0
and publish_step = 2
) as is_active_wedding,

# VIRAL WEDDING FLAG(1=yes,0=no)

# - Defined as any member (admin or guest but not super admin) who creates a wedding after they 
# become part of the wedding
# - If a user was as Super admin before, and attended the any wedding later as guest/admin, 
# he/she would not included for the viral wedding contribution.
# - cnt - the number of weddings initiated by the user after attending the weddin as non super admin
# var : is_viral_wedding - flag to indicate the whether active wedding or not ( specific to the wedding_id)


(select case when sum((select count(*) from wedpics_test.users_weddings f
where f.is_admin = 'S'
and f.created_at > d.created_at 
and f.user_id = d.user_id
)) >= 1 then 1 else 0 end as cnt
from wedpics_test.users_weddings d
where (d.is_admin <> 'S' or d.is_admin is null)
and d.wedding_id = a.id
) as is_viral_wedding,


# SUCCESSFUL WEDDING FLAG(1=yes,0=no)
# var : is_successful_wedding - flag to indicate the whether SUCCESSFUL wedding or not ( specific to the wedding_id)

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
date(a.wedding_date) between '2014-11-01' and '2014-12-31'
and a.payment = 1 
and a.is_deleted = 0
and b.is_admin = 'S'
ORDER BY is_viral_wedding desc
) as q
group by DiffDate
)
"""
query2 = """

# col : DiffDate            - The number of days between wedding created and the wedding date 
# col : num_weddings        -  Overall weddings in the given time frame

# we shall take the total wedding numbers in the period specified - Nov - Dec,2015

create table tmp_overallweddings as (
select DATEDIFF(a.wedding_date,a.created_at) AS DiffDate,count(*) as num_weddings
from wedpics_test.weddings a
left join wedpics_test.users_weddings b 
on a.id = b.wedding_id
where 
date(a.wedding_date) between '2014-11-01' and '2014-12-31'
and a.payment = 1 
and a.is_deleted = 0
and b.is_admin = 'S'
group by DiffDate
order by num_weddings desc
)
"""

query3 = """
#----------------------------------------THE FINAL RESULTS TABLE---------------------------------------

# col : Active_percent       -  Percent active weddings in the given time frame
# col : Successful_percent   -  Percent active weddings in the given time frame
# col : Viral_percent        -  Percent active weddings in the given time frame

select 
a.*,
round((a.Active_weddings/b.num_weddings) * 100,0) as Active_percent ,
round((a.Successful_weddings/b.num_weddings) * 100,0) as Successful_percent ,
round((a.Viral_weddings/b.num_weddings) * 100,0) as Viral_percent,
b.num_weddings

from tmp_output a 
inner join tmp_overallweddings b on a.DiffDate = b.DiffDate
"""

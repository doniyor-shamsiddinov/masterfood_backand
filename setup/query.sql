select
	o.order_id,
	o.order_paid,
	array_agg(s.steak_name) as steak_names,
	sum(os.count * s.steak_price) as price
from orders o
natural join order_sets os
inner join steaks s on s.steak_id = os.steak_id
group by o.order_id


select 
	steak_name
from steaks
where steak_id in (
	select steak_id from
	order_sets
	where count = 1
);


select 
	steak_name
from steaks
natural join order_sets os
where os.count between 3 and 5;

update order_sets set 
count = 5
where order_set_id = 4;


with old_data as (
	select 
		steak_id,
		steak_name,
		steak_price
	from steaks
	where steak_id = 1
) update steaks s set
	steak_name = 'combo 2',
	steak_price = o.steak_price + 2000
from old_data o
where s.steak_id = 1
returning s.steak_id, o.steak_price as old_price, s.steak_price as new_price;


select
	o.order_id,
	o.order_paid,
	o.order_created_at,
	t.table_number,
	sum(os.order_set_price) as order_total_price,
	json_agg(os)
from orders o
natural join tables t
inner join (
	select
		order_id,
		order_set_price,
		count,
		steak_name
	from order_sets 
	natural join steaks
) as os on os.order_id = o.order_id
group by o.order_id;


with x as (
	select
		o.table_id,
		o.order_paid
	from orders o
	natural join tables t
	where t.table_id = 2
	order by order_created_at desc
	limit 1
) insert into orders (
	table_id
) select x.table_id from x
where x.order_paid = true;


select distinct on(t.table_id)
    t.table_id,
    t.table_number,
    case
        when o.order_paid = true then false
        else true
    end as table_busy,
    case
        when o.order_paid = true then null
        else row_to_json(o)
    end as order
from tables t
inner join (
    select * from orders 
    order by order_created_at desc
) as o on o.table_id = t.table_id
order by t.table_id;

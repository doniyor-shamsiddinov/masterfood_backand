create database masterfood;

create table steaks (
	steak_id int generated always as identity primary key,
	steak_name varchar(50) not null,
	steak_img varchar(256) not null,
	steak_price int not null
);

create table tables (
	table_id int generated always as identity primary key,
	table_number smallint not null
);

create table orders (
	order_id int generated always as identity primary key,
	table_id int not null references tables (table_id) on delete cascade,
	order_paid bool default false,
	order_created_at timestamptz default current_timestamp
);

create table order_sets (
	order_set_id int generated always as identity primary key,
	count smallint not null,
	steak_id int not null references steaks(steak_id) on delete cascade,
	order_id int not null references orders(order_id) on delete cascade,
	order_set_price int not null
);


insert into steaks (steak_name, steak_price, steak_img) values
('combo 1', 27000, 'https://picsum.photos/400'),
('lavash', 21000, 'https://picsum.photos/400'),
('haggi', 23000, 'https://picsum.photos/400'),
('Razliv', 6000, 'https://picsum.photos/400'),
('Cola 1', 8000, 'https://picsum.photos/400');


insert into tables (table_number) values (1);
insert into tables (table_number) values (2);
insert into tables (table_number) values (3);
insert into tables (table_number) values (4);


insert into orders (table_id) values (2);
insert into orders (table_id) values (3);

insert into order_sets (steak_id, order_id, count, order_set_price) values (2, 1, 2, 42000);
insert into order_sets (steak_id, order_id, count, order_set_price) values (3, 1, 1, 23000);

insert into order_sets (steak_id, order_id, count, order_set_price) values (1, 2, 1, 27000);
insert into order_sets (steak_id, order_id, count, order_set_price) values (5, 2, 1, 8000);


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


select 
	o.order_id,
	o.order_created_at,
	o.order_paid,
	t.table_number,
	sum(os.price) as order_total_price,
	json_agg(os)
	from orders o
	natural join tables t

	inner join (
		select
		os.order_set_id,
		os.count,
		os.order_id,
		os.order_set_price * os.count as price,
		row_to_json(s)
		from order_sets os
		natural join steaks s
		group by os.order_set_id, s.*
	) os on os.order_id = o.order_id
	group by o.order_id, t.table_number;


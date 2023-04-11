
CREATE TABLE dim_customers
(
 customer_id   varchar(15) NOT NULL,
 customer_name varchar(50) NOT NULL,
 segment       varchar(15) NOT NULL,
 CONSTRAINT PK_CUS PRIMARY KEY ( customer_id )
);


insert into dim_customers (customer_id,customer_name,segment) 
select customer_id, customer_name, segment from orders group by customer_id, customer_name, segment;




CREATE TABLE dim_date
(
 order_date date NOT NULL,
 year_       integer NOT NULL,
 quarter_    integer NOT NULL,
 month_      integer NOT NULL,
 week_day   varchar(15) NOT NULL,
 CONSTRAINT PK_DAT PRIMARY KEY ( order_date )
);

insert into dim_date (order_date,year_,quarter_,month_,week_day) 
select distinct order_date, extract(year from order_date), extract(quarter from order_date), extract(month from order_date), 
case when extract(dow from order_date)=0 then 'sunday'
	 when extract(dow from order_date)=1 then 'monday'
	 when extract(dow from order_date)=2 then 'tuesday'
	 when extract(dow from order_date)=3 then 'wednesday'
	 when extract(dow from order_date)=4 then 'thursday'
	 when extract(dow from order_date)=5 then 'friday'
	 when extract(dow from order_date)=6 then 'saturday'
end
from orders;





CREATE TABLE dim_geo
(
 geo_id      integer NOT NULL,
 country     varchar(25) NOT NULL,
 region      varchar(10) NOT NULL,
 state       varchar(30) NOT NULL,
 city        varchar(30) NOT NULL,
 postal_code integer,
 CONSTRAINT PK_GEO PRIMARY KEY ( geo_id )
);

insert into dim_geo (geo_id,country,region,state,city,postal_code) 
select 1000+row_number() over () as geo_id,country, region ,state ,city,postal_code
from orders
--where postal_code is not null
group by country, region ,state ,city,postal_code;





CREATE TABLE dim_products
(
	p_product_id integer not null,
 	product_id   varchar(15) NOT NULL,
 	product_name varchar(140) NOT NULL,
 	category     varchar(20) NOT NULL,
 	subcategory  varchar(20) NOT NULL,
 CONSTRAINT PK_PROD PRIMARY KEY ( p_product_id )
);

insert into dim_products (p_product_id ,product_id,product_name,category,subcategory) 
select 90000+row_number() over () as p_product_id,product_id, product_name, category,subcategory
from orders
group by product_id,product_name,category,subcategory;




CREATE TABLE dim_shipping
(
 ship_id   integer NOT NULL,
 ship_mode varchar(15) NOT NULL,
 CONSTRAINT PK_SHIP PRIMARY KEY ( ship_id )
);

insert into dim_shipping (ship_id,ship_mode)
select 100+row_number() over () as ship_id, ship_mode
from orders
group by ship_mode;




CREATE TABLE sales_fact
(
 row_id       integer NOT NULL,
 sales        numeric NOT NULL,
 profit       numeric NOT NULL,
 order_id	  varchar(25) not null,
 p_product_id integer NOT NULL,
 customer_id  varchar(15) NOT NULL,
 order_date   date NOT NULL,
 geo_id       integer NOT NULL,
 ship_id      integer NOT NULL,
 CONSTRAINT PK_1 PRIMARY KEY ( row_id ),
 CONSTRAINT FK_CUS FOREIGN KEY ( customer_id ) REFERENCES dim_customers ( customer_id ),
 CONSTRAINT FK_SHIP FOREIGN KEY ( ship_id ) REFERENCES dim_shipping ( ship_id ),
 CONSTRAINT FK_GEO FOREIGN KEY ( geo_id ) REFERENCES dim_geo ( geo_id ),
 CONSTRAINT FK_PROD FOREIGN KEY ( p_product_id ) REFERENCES dim_products ( p_product_id ),
 CONSTRAINT FK_DAT FOREIGN KEY ( order_date ) REFERENCES dim_date ( order_date )
);

CREATE INDEX FK_CUS ON sales_fact
(
 customer_id
);

CREATE INDEX FK_SHIP on sales_fact
(
 ship_id
);

CREATE INDEX FK_GEO ON sales_fact
(
 geo_id
);

CREATE INDEX FK_PROD ON sales_fact
(
 p_product_id
);

CREATE INDEX FK_DAT ON sales_fact
(
 order_date
);

insert into sales_fact (row_id,sales,profit,p_product_id,customer_id,order_date,geo_id,ship_id,order_id) 
select o.row_id,o.sales,o.profit,dp.p_product_id,o.customer_id,o.order_date,dg.geo_id,ds.ship_id,o.order_id
from
(select row_id,sales,profit,customer_id,order_date,order_id from orders
order by row_id) as o left join 
(select geo_id,row_id from dim_geo as dgg,orders as oo
where coalesce (dgg.postal_code,0)= coalesce (oo.postal_code,0)
and dgg.city = oo.city
order by row_id) as dg on o.row_id=dg.row_id left join 
(select p_product_id,dpp.product_id,dpp.product_name,row_id from dim_products dpp, orders oo
where dpp.product_id = oo.product_id
and dpp.product_name = oo.product_name
order by row_id) as dp on o.row_id=dp.row_id left join
(select ship_id,row_id from dim_shipping as dss,orders as oo
where dss.ship_mode=oo.ship_mode 
order by row_id) as ds on o.row_id=ds.row_id 




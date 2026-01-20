-- Create database Homework_session07_04
create database Homework_session07_04;
-- Create table
create table customer(
	customer_id serial primary key,
	full_name varchar(100),
	region varchar(50)
);
create table orders(
	order_id serial primary key,
	customer_id int references customer(customer_id),
	total_amount decimal(10,2),
	order_date date,
	status varchar(20)
);
create table product(
	product_id serial primary key,
	name varchar(100),
	price decimal(10,2),
	category varchar(50)
);
create table order_detail(
	order_id int references orders(order_id),
	product_id int references product(product_id),
	quantity int
);
insert into customer (full_name, region) values
('Nguyễn Văn An', 'Miền Bắc'),
('Trần Thị Bích', 'Miền Nam'),
('Lê Minh Cường', 'Miền Trung'),
('Phạm Thu Dung', 'Miền Bắc'),
('Hoàng Quốc Bảo', 'Miền Nam'),
('Vũ Thị Hạnh', 'Miền Bắc'),
('Đặng Ngọc Long', 'Miền Trung'),
('Bùi Phương Thảo', 'Miền Nam'),
('Đỗ Văn Kiên', 'Miền Bắc'),
('Hồ Thị Mai', 'Miền Trung'),
('Ngô Thanh Tùng', 'Miền Nam'),
('Dương Mỹ Linh', 'Miền Bắc'),
('Lý Văn Hùng', 'Miền Nam'),
('Vương Thị Tuyết', 'Miền Trung'),
('Trịnh Quang Huy', 'Miền Bắc');
insert into product (name, price, category) values
('Laptop Dell XPS', 25000000, 'Điện tử'),
('iPhone 15', 30000000, 'Điện tử'),
('Samsung TV 4K', 12000000, 'Điện tử'),
('Chuột Logitech', 500000, 'Phụ kiện'),
('Bàn phím cơ', 1500000, 'Phụ kiện'),
('Áo thun Polo', 300000, 'Thời trang'),
('Quần Jean Levi', 1200000, 'Thời trang'),
('Giày Nike Air', 2500000, 'Thời trang'),
('Nồi cơm điện Sharp', 1800000, 'Gia dụng'),
('Máy xay sinh tố', 800000, 'Gia dụng'),
('Tủ lạnh Toshiba', 8500000, 'Gia dụng'),
('Tai nghe Sony', 3500000, 'Điện tử'),
('Loa Bluetooth JBL', 2200000, 'Phụ kiện'),
('Balo chống sốc', 600000, 'Thời trang'),
('Đồng hồ Casio', 1500000, 'Thời trang');
insert into orders (customer_id, total_amount, order_date, status) values
(1, 25500000, '2023-10-01', 'Completed'),
(2, 1200000, '2023-10-02', 'Completed'),
(1, 500000, '2023-10-05', 'Completed'),
(3, 30000000, '2023-10-10', 'Processing'),
(4, 1500000, '2023-10-12', 'Cancelled'),
(5, 8500000, '2023-10-15', 'Completed'),
(2, 2500000, '2023-10-20', 'Processing'),
(6, 1800000, '2023-10-22', 'Completed'),
(7, 4200000, '2023-10-25', 'Completed'),
(8, 600000, '2023-11-01', 'Completed'),
(9, 3500000, '2023-11-05', 'Processing'),
(10, 800000, '2023-11-10', 'Completed'),
(11, 2200000, '2023-11-15', 'Cancelled'),
(5, 12000000, '2023-11-20', 'Completed'),
(12, 300000, '2023-11-25', 'Processing');
insert into order_detail (order_id, product_id, quantity) values
(1, 1, 1), (1, 4, 1),
(2, 7, 1),
(3, 4, 1),
(4, 2, 1),
(5, 15, 1),
(6, 11, 1),
(7, 8, 1),
(8, 9, 1),      
(9, 12, 1), (9, 4, 2),
(10, 14, 1),     
(11, 12, 1),    
(12, 10, 1),    
(13, 13, 1),         
(14, 3, 1),    
(15, 6, 1);    
-- Tạo View tổng hợp doanh thu theo khu vực
create view v_revenue_by_region as
select c.region, sum(o.total_amount) as total_revenue
from customer c join orders o on c.customer_id = o.customer_id
group by c.region;
-- Viết truy vấn xem top 3 khu vực có doanh thu cao nhất
select * from v_revenue_by_region
order by total_revenue desc limit 3 offset 0;

-- Tạo View chi tiết đơn hàng có thể cập nhật được
create materialized view mv_monthly_sales as
select date_trunc('month', order_date) as month, sum(total_amount) as monthly_revenue
from orders
group by date_trunc('month', order_date);
select * from mv_monthly_sales;
-- Cập nhật status của đơn hàng thông qua View này
update orders
set status = 'Cancelled'
where order_id = 5;
refresh materialized view mv_monthly_sales;
-- Kiểm tra hành vi khi vi phạm điều kiện WITH CHECK OPTION
create or replace view v_orders_processing as
select order_id, customer_id, total_amount, status
from orders
where status = 'Processing'
with check option;
select * from v_orders_processing;

-- Từ v_revenue_by_region, tạo View mới v_revenue_above_avg chỉ hiển thị khu vực có doanh thu > trung bình toàn quốc
create or replace view v_revenue_above_avg as
select region, total_revenue, (select avg(total_revenue) from v_revenue_by_region) as avg_revenue
from v_revenue_by_region
where total_revenue > (
	select avg(total_revenue)
	from v_revenue_by_region
);

select * from v_revenue_above_avg;
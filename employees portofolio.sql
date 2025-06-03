 #Soal 1 — Rata-rata Gaji per Departemen
#Tugas: Hitung rata-rata gaji untuk setiap departemen hanya untuk karyawan yang masih aktif :
select
	d.dept_name,
	avg(s.salary) as average_salary
from
	dept_emp de
join
	salaries s on de.emp_no = s.emp_no
join
	departments d on de.dept_no = d.dept_no
where
	de.to_date = '9999-01-01'
group by
	d.dept_name
order by
	average_salary desc;

# Soal 2 — Detail Karyawan Aktif
#Tugas: Tampilkan first_name, last_name, title, dan salary dari semua karyawan yang:
#Masih aktif (berdasarkan titles.to_date dan salaries.to_date)
#Urutkan berdasarkan gaji tertinggi ke terendah.	
	
select
    e.first_name,
    e.last_name,
    t.title,
    s.salary
from
	employees e
join
	salaries s on e.emp_no = s.emp_no
join
	titles t on s.emp_no = t.emp_no
where
	t.to_date = '9999-01-01' and s.to_date = '9999-01-01';
    
    
 #Soal 3 — Karyawan Pernah di 2 Jabatan
#Tugas: Ambil daftar emp_no, first_name, last_name dari karyawan yang pernah memegang lebih dari 1
# jabatan berbeda sepanjang kariernya di perusahaan.
#Hint: Pakai GROUP BY dan HAVING COUNT(DISTINCT title) > 1.

select
	e.emp_no,
    e.first_name,
    e.last_name
from
	employees e
join
	titles t on e.emp_no = t.emp_no
group by
	e.emp_no, e.first_name, e.last_name
having
	count(distinct title) >1;



select
	*
from
	employees e
join
	dept_emp de on e.emp_no = de.emp_no
where
	de.dept_no in
		(select
			d.dept_no
		from
			departments d
		where
			dept_name = 'Finance');

#"Ambil semua baris dari employees yang punya relasi ke dept_emp,
# dan hanya jika dept_no-nya ada dalam daftar dept_no dari tabel departments yang dept_name-nya 'Finance'."
# INTINYA ADALAH "GUE MAU NGAMBIL SEMUA DATA YANG ADA DI TABEL EMPLOYEES YANG SUDAH DIGABUNGKAN DENGAN DEPT_EMP,
# YANG MANA DEPT_NO YANG ADA DI DEPT_EMP ADALAH DEPT_NO YANG BERNAMA FINANCE.
# KARENA EMPLOYEES DAN DEPT_EMP SUDAH DIGABUNG JADI SATU (SUDAH DI JOIN) MAKA YANG KELUAR EMPLOYEE YANG BERADA
# DI DEPARTMENT SALES.

#Soal 4 — Gaji Manajer vs Non-Manajer
#Tugas: Hitung rata-rata gaji untuk:
#Manajer (lihat dept_manager)
#Non-manajer (semua karyawan yang tidak ada di dept_manager)
#Hint: Gunakan IN atau EXISTS, dan UNION ALL bisa digunakan kalau ingin hasil dalam satu tabel.
SELECT
    'Manager' AS role,
    AVG(s.salary) AS avg_salary
FROM
    salaries s
WHERE
    s.emp_no IN (SELECT emp_no FROM dept_manager)
    AND s.to_date = '9999-01-01'

UNION ALL

SELECT
    'Non-Manager' AS role,
    AVG(s.salary) AS avg_salary
FROM
    salaries s
WHERE
    s.emp_no NOT IN (SELECT emp_no FROM dept_manager)
    AND s.to_date = '9999-01-01';
    
    
select
	e.first_name,
    e.last_name,
    dm.emp_no
from
	employees e
join
	dept_manager dm on e.emp_no = dm.emp_no
where
	dm.emp_no in (
		select
			s.emp_no
		from
			salaries s
		where
			salary > '100000');
            
            
SELECT first_name, last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM dept_manager dm
    WHERE dm.emp_no = e.emp_no
);

SELECT
	e.first_name,
    e.last_name
from
	employees e
where exists (
	select *
    from dept_manager dm
    where e.emp_no = dm.emp_no);
    

#HASIL DIBAWAH ADALAH GABUNGAN DARI 2 SUBSET YANG BERBEDA
# kedua subset disatukan melalui UNION

SELECT
	A.*
FROM
	(select
		e.emp_no as employee_id,
		min(de.dept_no) as department_code,
			(select
				emp_no
			from
				dept_manager dm
			where
				dm.emp_no = '110022') as manager_id
	from
		employees e
	join 
		dept_emp de on e.emp_no = de.emp_no
	where
		e.emp_no <= '10020'
	group by
		e.emp_no
	order by
		e.emp_no asc) AS A
#INI ADALAH SUBSET A ATAU SUBSET 1 YANG MENGHASILKAN EMP_NO 110022 SEBAGAI MANAGER
# DARI EMP_NO dari 10001 - 10020 (group dari 20 employee 
# 10001-10020 yang 110022 sebagai managernya)
# INNER QUERY NYA AKAN MENAMPILKAN EMP_NO YANG DINAUNGI OLEH MANAGER 1110022

UNION

SELECT
	B.*
FROM
	(select
		e.emp_no as employee_id,
		min(de.dept_no) as department_code,
			(select
				emp_no
			from
				dept_manager dm
			where
				dm.emp_no = '110039') as manager_id
	from
		employees e
	join 
		dept_emp de on e.emp_no = de.emp_no
	where
		e.emp_no > '10020'
	group by
		e.emp_no
	order by
		e.emp_no asc
	LIMIT 20
		) AS B;
 #INI ADALAH SUBSET B ATAU SUBSET 2 YANG MENGHASILKAN EMP_NO 110039 SEBAGAI MANAGER
# DARI EMP_NO dari 100021 - 10040 (group dari 20 employee 
# 10021-10040 yang 110039 sebagai managernya)
# INNER QUERY NYA AKAN MENAMPILKAN EMP_NO YANG DINAUNGI OLEH MANAGER 1110022




-- MELIHAT EMP.NO MANAGER YANG MASIH AKTIF DAN DEPARTEMENT NYA
select
	dm.emp_no,
    d.dept_name,
    d.dept_no
from
	dept_manager dm
join
	departments d on dm.dept_no = d.dept_no
where
	dm.to_date = '9999-01-01';

select * from employees where emp_no = '110039';


select
	e.emp_no,
    e.first_name,
    e.last_name,
    dm.dept_no
from
	employees e
join
	dept_manager dm on e.emp_no = dm.emp_no
where dm.dept_no in
	(select
		d.dept_no
	from
		departments d
	where
		d.dept_name = 'sales' and dm.to_date = '9999-01-01');
# DISINI GUE MAU CARI TAU INFO EMP NO, FIRSTNAME, LASTNAME DAN DEPT_NO DARI MANAGER SALES YANG MASIH MENJABAT


SELECT
	dm.emp_no,
    e.first_name,
    e.last_name
from
	employees e
join
	dept_manager dm on e.emp_no = dm.emp_no
where
	dm.dept_no in
		(select
			d.dept_no
		from
			departments d
		where
			dept_name = 'Customer Service' and dm.to_date = '9999-01-01');
-- mencari emp no first name dan last name dari manager customer service yang masih aktif (menggunakan sub queries)


select
	d.dept_name,
    sum(case when e.gender = 'M' then 1 else 0 end) as count_male,
    sum(case when e.gender = 'F' then 1 else 0 end) as count_female
from
	employees e
join
	dept_emp de on e.emp_no = de.emp_no
join
	departments d on de.dept_no = d.dept_no
where
	de.to_date = '9999-01-01'
group by
	d.dept_name
order by
	d.dept_name;
-- mencari tahu ada berapa jumlah employee yang masih aktif berdasarkan department dan gender



#STORED ROUTINE
# DELIMETER
DELIMITER $$
CREATE PROCEDURE all_employees()
BEGIN
	SELECT
		*
	FROM
		employees e
	LIMIT 10;
END$$
DELIMITER ;

CALL all_employees();

DELIMITER $$
CREATE PROCEDURE Average_emp_salary()
BEGIN
	SELECT
		'Employees' as average_salary,
		avg(s.salary)
	FROM
		salaries s;
END $$

DELIMITER ;

call average_emp_salary();

DELIMITER $$
CREATE PROCEDURE comparison_manager_nonmanager_salary()
BEGIN
	select
		'Manager' as role,
		avg(s.salary) as average_salary
	from
		salaries s
	where
		s.emp_no in(
			select
				dm.emp_no
			from dept_manager dm)
        
UNION ALL

	SELECT
		'Non Manager' as role,
		avg(s.salary) as average_salary
	from
		salaries s
	where
		s.emp_no not in(
			select
				dm.emp_no
			from
				dept_manager dm);
END $$
DELIMITER ;

CALL comparison_manager_nonmanager_salary();


######## stored procedure with in parameter
delimiter $$
create procedure emp_salary (in p_emp_no integer)
begin
select
	e.first_name,
    e.last_name,
    s.salary,
    s.from_date,
    s.to_date
from
	employees e
join
	salaries s on e.emp_no = s.emp_no
where
	e.emp_no = p_emp_no;
end$$

delimiter ;
call emp_salary(11200);


########### stored procedure with in and out parameter

DELIMITER $$
CREATE PROCEDURE emp_avg_salary_out(in p_emp_no integer,
                                    out p_avg_salary decimal(10,2),
                                    out p_first_name varchar(15),
                                    out p_last_name varchar(15))
BEGIN
SELECT
	avg(s.salary),
    e.first_name,
    e.last_name
INTO
	p_avg_salary,
    p_first_name,
    p_last_name
from
	employees e
join 
	salaries s on e.emp_no = s.emp_no
where
	e.emp_no = p_emp_no;
end $$
DELIMITER ;




with dup as(
select
	e.emp_no,
    e.first_name,
    e.last_name,
    d.dept_name,
    s.salary as salary,
    case
		when s.salary > 60000 then 'gausah naik gaji'
        else 'naikin gaji'
	end as keterangan
from
	employees e
join
	dept_emp de on e.emp_no = de.emp_no
join
	departments d on de.dept_no = d.dept_no
join
	salaries s on e.emp_no = s.emp_no
where
	de.to_date = '9999-01-01' and s.to_date = '9999-01-01')
select
	sum(case when keterangan = 'gausah naik gaji' then 1 else 0 end) as count_ganaik,
    sum(case when keterangan = 'naikin gaji' then 1 else 0 end) as count_naik
from
	dup;
-- mencari e.emp_no, first name, last name serta departement dari employee yang gajinya masih dibawah 60000


select
	e.emp_no,
    e.first_name,
    e.last_name,
    t.title,
   avg(s.salary) as average_salary,
    case
		when avg(s.salary) > 60000 then 'gaada kenaikan gaji'
        when avg(s.salary) between 40000 and 50000 then 'naikin gaji 5000'
        else 'NAIKIN GAJI SAMPE 55000'
        end as kenaikan_gaji
from
	employees e
join
	salaries s on e.emp_no = s.emp_no
join
	titles t on e.emp_no = t.emp_no
where
	t.title = 'staff' and t.to_date = '9999-01-01'
group by
	e.emp_no;
-- mencari gaji yang berjabatan staff yang masih dibawah 60 ribu
# ini masih bisa di upgrade. KITA BISA BANDINGIN
# RATA-RATA GAJI JABATAN STAFF DAN STAFF YANG GAJINYA MASIH DIBAWAH RATA-RATA


SELECT
    e.emp_no,
    e.first_name,
    e.last_name,
    d.dept_name,
    s.salary,
    RANK() OVER (PARTITION BY d.dept_name ORDER BY s.salary DESC) AS salary_rank
FROM
    employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON de.dept_no = d.dept_no
JOIN salaries s ON e.emp_no = s.emp_no
WHERE
    de.to_date = '9999-01-01'
    AND s.to_date = '9999-01-01';
-- melihat salary rank per departement menggunakan window function


select
	t.title,
    avg(case when e.gender = 'M' then s.salary end) as average_male_salary,
    avg(case when e.gender = 'F' then s.salary end) as average_female_salary
from
	employees e
join
	titles t on e.emp_no = t.emp_no
join
	salaries s on e.emp_no = s.emp_no
where
	s.to_date = '9999-01-01'
group by
	t.title
order by
	average_male_salary desc;
-- mencari average male dan female salary per jabatan (menggunakan case statement)


#######################
# 1. Number of employee by year and gender
select
	Year(de.from_date) as calendar_year,
    e.gender as gender,
    count(e.emp_no) as num_of_employee
from
	employees e
join
	dept_emp de on e.emp_no = de.emp_no
group by
	calendar_year,
    gender
having
	calendar_year >= 1990
order by calendar_year;


# 3.   
-- STEP 1. rata-rata gaji tiap department
with dept_avg_salary as (
select
	d.dept_name,
    avg(s.salary) as dept_avg
from
	salaries s
join
	dept_emp de on s.emp_no = de.emp_no
join
	departments d on de.dept_no = d.dept_no
where
	de.to_date = '9999-01-01' and
	s.to_date = '9999-01-01'
group by
	d.dept_name),
    
    
-- STEP 2. rata-rata gaji employee

emp_avg_salary as (
select
	e.emp_no,
    d.dept_name,
    avg(s.salary) as emp_avg
from
	employees e
join
	salaries s on e.emp_no = s.emp_no
join
	dept_emp de on e.emp_no = de.emp_no
join
	departments d on de.dept_no = d.dept_no
where
	s.to_date = '9999-01-01' and
    de.to_date = '9999-01-01'
group by
	e.emp_no,
    d.dept_name)
    
 -- STEP 3. Bandingkan employee average salary vs dept average
 
select
	ea.dept_name,
    count(*) as emp_below_avg,
    da.dept_avg
from
	emp_avg_salary ea
join
	dept_avg_salary da on ea.dept_name = da.dept_name
where
	ea.emp_avg < da.dept_avg
group by
	ea.dept_name,
    da.dept_avg
order by
	emp_below_avg;
-- mencari employee di tiap department yang gajinya masih dibawah rata-rata gaji department



with max_salary as (
select
	de.emp_no,
    d.dept_name,
    max(s.salary) as max_salary
from
	dept_emp de
join
	salaries s on de.emp_no = s.emp_no
join
	departments d on de.dept_no = d.dept_no
where
	s.to_date = '9999-01-01'
group by
	d.dept_no
)
    
select
	de.emp_no,
    d.dept_name,
    s.salary
from
	dept_emp de
join
	salaries s on de.emp_no = s.emp_no and s.to_date = '9999-01-01'
join
	departments d on de.dept_no = d.dept_no
join
	max_salary ms on d.dept_name = ms.dept_name and s.salary = ms.max_salary
order by
	salary desc;
-- mencari employee yang mempunyai gaji paling tinggi di tiap department





with title_avg_salary as
(
select
	t.title,
    avg(s.salary) as average_title
from
	employees e
join
	salaries s on e.emp_no = s.emp_no
join
	titles t on s.emp_no = t.emp_no
where
	s.to_date = '9999-01-01' and t.to_date = '9999-01-01'
group by
	t.title
),

emp_avg_salary as
(
select
	e.emp_no,
    t.title,
    s.salary as emp_salary
from
	employees e
join
	salaries s on e.emp_no = s.emp_no
join
	titles t on s.emp_no = t.emp_no
where
	s.to_date = '9999-01-01' and t.to_date = '9999-01-01'
group by
	e.emp_no,
    t.title
)

select
	ta.title,
    count(*) as count_emp_below_avg,
    ta.average_title
from
	title_avg_salary ta
join
	emp_avg_salary ea on ta.title = ea.title
where
	ea.emp_salary < ta.average_title
group by
	ta.title;
-- menghitung berapa orang yang gajinya masih dibawah rata-rata tiap jabatan.




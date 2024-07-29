create table cust_org_partitioned (like student25.cust_org including all);
drop table cust_org_partitioned cascade;

--функция создает партиции первого уровня
create or replace function create_part_1(text[][]) 
returns void as $$
declare
  x text[];
begin
  foreach x slice 1 in array $1
  loop
	  	execute 'drop table if exists cust_org_1_prt_' || x[1] || ' cascade';
		execute 'create table cust_org_1_prt_' || x[1] ||
		E'(
			check (right(inn, 1) = \'' || x[2] || E'\')
		) 
		inherits (student25.cust_org_partitioned)';
	  		  
  end loop;
end;
$$ language plpgsql;

select create_part_1(array[['zero', '0'], ['one', '1'], ['two', '2'], ['three', '3'], 
						['four', '4'], ['five', '5'], ['six', '6'], ['seven', '7'], 
						['eight', '8'], ['nine', '9']]);

/*
 * функция создает партиции второго уровня 
 * + создает правила, которые соблюдаются при добавлении данных в таблицу cust_org_partitioned,
 * таким образом мы данные расскидываем по нужным партициям
 */ 
create or replace function create_part_2(text[][], text[][]) 
returns void as $$
declare
  x text[];
  y text[];
begin
  foreach x slice 1 in array $1
  loop
	  foreach y slice 1 in array $2
      loop
			      
		execute 'create table cust_org_1_prt_' || x[1] || '_2_prt_' || y[1] ||
		E'(
			check (right(inn, 1) = \'' || x[2] || E'\')
			, check (okopf_code = \'' || y[2] || E'\')
		) 
		inherits (student25.cust_org_1_prt_' || x[1] || ')';
	  				
		execute 'create or replace rule rule_' || x[1] || '_' || y[1] || E' as 
				on insert to cust_org_partitioned where
					(
						right(inn, 1) = \'' || x[2] || E'\' 
						and okopf_code = \'' || y[2] || E'\'
					)
				do instead 
					insert into cust_org_1_prt_' || x[1] || '_2_prt_' || y[1] || ' values (new.*)';
      end loop;
  end loop;
end;
$$ language plpgsql;


select create_part_2(array[['zero', '0'], ['one', '1'], ['two', '2'], ['three', '3'], 
						['four', '4'], ['five', '5'], ['six', '6'], ['seven', '7'], 
						['eight', '8'], ['nine', '9']], array[['individual', '91'], 
						['filial', '90'], ['сlose', '67'], ['limited', '65']]);

--функция для создания default партиций второго уровня и правил 
create or replace function create_part_other(text[][], text[][]) 
returns void as $$
declare
  x text[];
  y text[];
begin
  foreach x slice 1 in array $1
  loop
	  foreach y slice 1 in array $2
      loop
			      
		execute 'create table cust_org_1_prt_' || x[1] || '_2_prt_' || y[1] ||
		E'(
			check (right(inn, 1) = \'' || x[2] || E'\')
		) 
		inherits (student25.cust_org_1_prt_' || x[1] || ')';
	  				
		execute 'create or replace rule rule_' || x[1] || '_' || y[1] || E' as 
				on insert to cust_org_partitioned where
					(
						okopf_code not in (\'91\', \'90\', \'67\', \'65\') or okopf_code is null and
						right(inn, 1) = \'' || x[2] || E'\' 
					)
				do instead 
					insert into cust_org_1_prt_' || x[1] || '_2_prt_' || y[1] || ' values (new.*)';
      end loop;
  end loop;
end;
$$ language plpgsql;


select create_part_other(array[['zero', '0'], ['one', '1'], ['two', '2'], ['three', '3'], 
						['four', '4'], ['five', '5'], ['six', '6'], ['seven', '7'], 
						['eight', '8'], ['nine', '9']], array[['other_okopf', '']]);

--переносим данные из старой таблицы в новую					
insert into cust_org_partitioned
select * from cust_org;

--удаляем исходную таблицу и назначаем имя удаленной таблицы партиционированной таблице
drop table cust_org;
alter table cust_org_partitioned rename to cust_org;

explain analyze select * from cust_org
where right(inn, 1) = '7' and okopf_code = '65'; 

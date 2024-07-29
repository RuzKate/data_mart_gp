/*
 * функция, которая добавляет данные в витрину cust_org
 */
create or replace function insert_data_cust_org() returns void
as $$
begin
	truncate cust_org;
	create table tax_registration as 
	select cl.id, 
			(ins.c_reg_doc_ser ||';'|| ins.c_reg_doc_numb ||';'|| 
			to_char(to_date(ins.c_reg_doc_date, 'YY.MM.DD'),'DD.MM.YYYY') ||';'||
			ct.c_name) as fns_registration_doc
	   from client as cl 
	   left join tax_insp as ins 
	     on ins.collection_id = cl.c_inspect 
	   left join tax_inspect as insp 
	     on insp.id = ins.c_name
	   left join names_city as ct 
	     on ct.id = insp.c_city
	   left join region as rgn 
	     on rgn.id = insp.c_district
	distributed by (id);

	create table client_legal_address as 
	select cl.id as cl_id,
			(ads1.c_post_code || ', ' || ci.c_name || ', ' || 
			ads1.c_street || ', ' || ads1.c_house || ', ' || 
			coalesce(ads1.c_korpus, ads1.c_building_number) || ', ' || ads1.c_flat) as list_address
	  from personal_address as ads1
	  join client as cl 
		on cl.c_addresses = ads1.collection_id 
	  join address_type as at1 
		on ads1.c_type = at1.id 
	  left join names_city as ci 
		on ads1.c_city = ci.id 
	 where at1.c_kod = 'CORP'
	distributed by (cl_id);

	create table client_fact_address as 
	select cl.id as cl_id,
			(ads1.c_post_code || ', ' || ci.c_name || ', ' || 
			ads1.c_street || ', ' || ads1.c_house || ', ' || 
			coalesce(ads1.c_korpus, ads1.c_building_number) || ', ' || ads1.c_flat) as list_address
	  from personal_address as ads1
	  join client as cl 
		on cl.c_addresses = ads1.collection_id 
	  join address_type as at1 
		on ads1.c_type = at1.id 
	  left join names_city as ci 
		on ads1.c_city = ci.id 
	 where at1.c_kod = 'FACT'
	distributed by (cl_id);

	create table phone_list as
	select cnt.collection_id,
			string_agg(cnt.c_numb, '#') as list_phone 
	  from contacts as cnt 
	  left join comunication as cmnc 
	    on cmnc.id = cnt.c_type 
	 where cmnc.c_code in ('PHONE','MOBILEPHONE') 
	 group by cnt.collection_id
	distributed by (collection_id);

	create table fax_list as
	select cnt.collection_id,
			string_agg(cnt.c_numb, '#') as list_fax 
	  from contacts as cnt 
	  left join comunication as cmnc 
	    on cmnc.id = cnt.c_type 
	 where cmnc.c_code in ('FAX') 
	 group by cnt.collection_id
	 distributed by (collection_id);

	create table email_list as
	select cnt.collection_id,
			string_agg(cnt.c_numb, '#') as list_email 
	  from contacts as cnt 
	  left join comunication as cmnc 
	    on cmnc.id = cnt.c_type 
	 where cmnc.c_code in ('MAIL') 
	 group by cnt.collection_id
	distributed by (collection_id);

	create table chief as 
	select pers.collection_id,
			string_agg(clfl.c_name, ',') as namepers 
	  from persons_pos as pers 
	  left join client as clfl 
	    on pers.c_fase = clfl.id
	 where pers.c_chief = '1' 
	 group by pers.collection_id
	distributed by (collection_id);

	create table t_chief_accountant_name as 
	select pers.collection_id,
			string_agg(clfl.c_name, ',') as namepers 
	  from persons_pos as pers 
	  left join client as clfl 
	    on pers.c_fase=clfl.id
	  join casta as c
	    on c.id = pers.c_range
	 where pers.c_general_acc = '1' 
	    or upper(c.c_value) = 'ГЛАВНЫЙ БУХГАЛТЕР' 
	 group by pers.collection_id
	distributed by (collection_id);

	create table t_business_segment_name as
	select cl.id,
			clg.c_name
	  from cl_categories as cat
	  join client as cl
	    on cl.c_vids_cl = cat.collection_id
	  join cl_group as clg
	  	on clg.id = cat.c_category
	distributed by (id);

	create table bank_and_elim_info as 
	select c.id as id_client,
			row_number () over (partition by c.id order by stc.c_lim_date desc, stc.id desc) as ord,
			(case when ir.c_code like 'BANKRUPT%' then 'b'
				when ir.c_code like 'LIQUIDATION%' then 'l' 
			end) as code,
			concat_ws(';', coalesce(stc.id, ''), coalesce(stc.c_kind_limit, ''), 
			coalesce(stc.c_reason, ''), coalesce(ir.c_name, ''),
			coalesce(to_char(to_date(stc.c_date_begin, 'DD.MM.YY'), 'DD.MM.YYYY'), ''),
			coalesce(to_char(to_date(stc.c_date_end, 'DD.MM.YY'), 'DD.MM.YYYY'), ''), 
			coalesce(stc.c_lim_num, ''), 
			coalesce(to_char(to_date(stc.c_lim_date, 'DD.MM.YY'), 'DD.MM.YYYY'), ''), coalesce(stc.c_dop_info, '')) as info
	  from ins_restrict as ir 
	  join st_client as stc
		on stc.c_kind_limit = ir.id 
	  join client as c
		on stc.collection_id = c.c_state_stage
	  where (to_date(stc.c_date_begin, 'DD.MM.YY') <= current_date or stc.c_date_begin is null) 
	    and (to_date(stc.c_date_end, 'DD.MM.YY') > current_date or stc.c_date_end is null) 
	    and (ir.c_code like 'BANKRUPT%' or ir.c_code like 'LIQUIDATION%')
	  group by c.id, stc.id, stc.c_kind_limit, stc.c_reason, ir.c_name, 
	           stc.c_date_begin, stc.c_date_end, stc.c_lim_num, stc.c_dop_info, 
	           stc.c_lim_date, ir.c_code
	distributed by (id_client);

	create table client_id_fl as
	select clc.id,
			string_agg(zp.c_fase, '#') as c_fase 
	  from persons_pos as zp 
	  left join casta as c 
	    on c.id = zp.c_range 
	  join cl_corp as clc 
	    on clc.c_all_boss = zp.collection_id
	  left join form_property as fpr
		on fpr.id = clc.c_forma
	 where c.c_code = 'C_IP'
		or ((upper(c.c_value) like '%ИНД%' 
		or upper(c.c_value) like '%ПРЕДПРИ%'
		or fpr.c_short_name = 'ИП' 
		or upper(c.c_value) like '%ПРЕЗИДЕНТ%') 
	   and coalesce(zp.c_chief, '1') = '1')
     group by clc.id
   	distributed by (id);
   
   --добавляем данные в витрину
	insert into cust_org(
		tech_change_time,
		client_id,
		name,
		short_name,
		eng_name,
		okopf_code,
		okopf_name, 
		okfc_code, 
		okfc_name,
		type_of_activity,
		country_name,
		inn,
		kio,
		kpp_main, 
		ogrn,  
		registration_date,
		registration_doc,
		registration_authority_name, 
		fns_registration_date,
		fns_registration_doc, 
		okato_code,
		authorized_capital_amt,
		list_legal_address,
		list_fact_address,
		list_phone,
		list_fax,
		list_email,
		swift,
		is_currency_residence,
		is_tax_resident,
		director_name,
		chief_accountant_name,
		business_segment_name,
		bankruptcy_info,
		elimination_info,
		service_start_date,
		bic,
		reg_num,
		corr_acc_num,
		list_natural_client_id
	)
	select to_char(now()::timestamp, 'DD.MM.YYYY HH24:MI:SS.MS') as tech_change_time,
			cl.id as client_id,
			clc.c_long_name as name,
			cl.c_name as short_name,
			cl.c_i_name as eng_name,
			fpr.c_code as okopf_code, 
			fpr.c_name as okopf_name, 
			ot.c_short_name as okfc_code, 
			ot.c_name as okfc_name,
			clo.c_business as type_of_activity,
			country.c_name as country_name,
			cl.c_inn as inn,
			cl.c_kio as kio,
			coalesce(cl.c_crr, cl.c_kpp) as kpp_main, 
			clc.c_register_gos_reg_num_rec as ogrn, 
			to_char(to_date(clc.c_register_date_reg, 'DD.MM.YY'), 'YYYYMMDD')  as registration_date,
			clc.c_register_ser_svid || ' ' || clc.c_register_num_svid as registration_doc,
			coalesce(clc1.c_long_name, reg.c_name) as registration_authority_name, 
			to_char(to_date(ins.c_date, 'DD.MM.YY'), 'YYYYMMDD') as fns_registration_date,
			tr.fns_registration_doc, 
			cl.c_okato_code as okato_code,
			coalesce(clc.c_register_declare_uf, clc.c_register_paid_uf) || '.00' as authorized_capital_amt,
			concat('[', cla.list_address, ']') as list_legal_address,
			concat('[', cfa.list_address, ']') as list_fact_address,
			concat('[', pl.list_phone, ']') as list_phone,
			concat('[', fl.list_fax, ']') as list_fax,
			concat('[', el.list_email, ']') as list_email,
			cb.c_swift_c as swift,
			cl.c_resident as is_currency_residence,
			cl.c_taxr as is_tax_resident,
			chief.namepers as director_name,
			tcan.namepers as chief_accountant_name,
			tbsn.c_name as business_segment_name,
			bankruptcy.info as bankruptcy_info,
			liquidation.info as elimination_info,
			to_char(to_date(cl.c_crt_dat, 'DD.MM.YY'), 'YYYYMMDD') as service_start_date,
			cbn.c_bic as bic,
			cbn.c_reg_num as reg_num,
			cbn.c_ks as corr_acc_num,
			concat('[', clfl.c_fase, ']') as list_natural_client_id 
	
	  from client as cl 
	  join cl_corp as clc
	    on clc.id = cl.id
	  join form_property as fpr
	 	on fpr.id = clc.c_forma
	  left join ownership_type as ot 
	    on ot.id = clc.c_ownership
	  join cl_org as clo
	 	on clo.id = cl.id
	  join country
	  	on country.id = cl.c_country
	  	 	
	  left join cl_corp as clc1
	 	on clc1.id = clc.c_register_reg_body
	  left join (select c.id,
	  				c.c_name
		   	  from client as c
		   	  join cl_corp as clc2
		   	    on clc2.id = c.id
		      join cl_corp as clc3
		        on clc3.id = clc2.c_register_reg_body
		       and c.id = clc3.id) as reg
		on reg.id = cl.id	 
	 
	  left join tax_insp as ins 
	 	on ins.collection_id = cl.c_inspect
	  left join tax_registration as tr 
	 	on tr.id = cl.id
	 
	  left join client_legal_address as cla 
	 	on cla.cl_id = cl.id
	  left join client_fact_address as cfa 
	 	on cfa.cl_id = cl.id
	
	  left join phone_list as pl
	 	on pl.collection_id = cl.c_contacts
	  left join fax_list as fl
	 	on fl.collection_id = cl.c_contacts
	  left join email_list as el
	 	on el.collection_id = cl.c_contacts
	 
	  left join cl_bank as cb 
	    on cb.id = cl.id
	  left join chief 
	    on chief.collection_id = clc.c_all_boss
	  left join t_chief_accountant_name as tcan
	    on tcan.collection_id = clc.c_all_boss 
	  left join t_business_segment_name as tbsn
	  	on tbsn.id = cl.id
	  	
	  left join bank_and_elim_info as bankruptcy
		on bankruptcy.id_client = cl.id
	   and bankruptcy.code = 'b'
	   and bankruptcy.ord = 1
	
	  left join bank_and_elim_info as liquidation
	 	on liquidation.id_client = cl.id
	   and liquidation.code = '|'
	   and liquidation.ord = 1
	  
	  left join cl_bank_n as cbn
	 	on cbn.id = cl.id
	 
	  left join client_id_fl as clfl
		on clfl.id = cl.id; 
	
	drop table tax_registration;
	drop table client_legal_address;
	drop table client_fact_address;
	drop table phone_list;
	drop table fax_list;
	drop table email_list;
	drop table chief;
	drop table t_chief_accountant_name;
	drop table t_business_segment_name;
	drop table bank_and_elim_info;
	drop table client_id_fl;

end;
$$ language plpgsql;

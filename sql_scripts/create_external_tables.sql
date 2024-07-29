create external table cl_corp(
	id text,
	c_all_boss text,
	c_register_reg_body text,
	c_ownership text,
	c_forma text,
	c_register_declare_uf text,
	c_register_paid_uf text,
	c_register_ser_svid text,
	c_register_num_svid text,
	c_register_date_reg text,
	c_register_gos_reg_num_rec text,
	c_long_name text
)
location (
	'gpfdist://10.30.104.107:8081/CL_CORP.csv'
)
format 'csv' (header delimiter '^');


create external table client(
	id text,
	c_inspect text,
	c_state_stage text,
	c_country text,
	c_contacts text,
	c_okved_array text,
	c_vids_cl text,
	c_okved_in_period text,
	c_addresses text,
	c_okato_code text,
	c_name text,
	c_i_name text,
	c_inn text,
	c_kio text,
	c_crr text,
	c_kpp text,
	c_resident text,
	c_taxr text,
	c_crt_dat text
) 
location (
	'gpfdist://10.30.104.107:8081/CLIENT.csv'
)
format 'csv' (header delimiter '^');


create external table student25.personal_address(
	id text,
	collection_id text,
	c_type text,
	c_city text,
	c_post_code text,
	c_street text,
	c_house text,
	c_korpus text,
	c_building_number text,
	c_flat text
)
location (
	'gpfdist://10.30.104.107:8081/PERSONAL_ADDRESS.csv'
)
format 'csv' (header delimiter '^');

create external table address_type(
	id text,
	c_kod text,
	c_name text
)
location (
	'gpfdist://10.30.104.107:8081/ADDRESS_TYPE.csv'
)
format 'csv' (header delimiter '^');


create external table names_city(
	id text,
	c_name text,
	c_cod_city text,
	c_country text,
	c_status text,
	c_people_place text
)
location (
	'gpfdist://10.30.104.107:8081/NAMES_CITY.csv'
)
format 'csv' (header delimiter '^');


create external table contacts(
	id text,
	collection_id text,
	c_type text,
	c_numb text,
	c_dat_edt text
)
location (
	'gpfdist://10.30.104.107:8081/CONTACTS.csv'
)
format 'csv' (header delimiter '^');


create external table comunication(
	id text,
	c_code text,
	c_value text
)
location (
	'gpfdist://10.30.104.107:8081/COMUNICATION.csv'
)
format 'csv' (header delimiter '^');


create external table persons_pos(
	id text,
	c_fase text,
	collection_id text,
	c_chief text,
	c_range text,
	c_general_acc text,
	c_work_end text,
	c_work_begin text
)
location (
	'gpfdist://10.30.104.107:8081/PERSONS_POS.csv'
)
format 'csv' (header delimiter '^');


create external table casta(
	id text,
	c_value text,
	c_code text
)
location (
	'gpfdist://10.30.104.107:8081/CASTA.csv'
)
format 'csv' (header delimiter '^' quote '''');


create external table tax_insp(
	id text,
	collection_id text,
	c_name text,
	c_reg_doc_ser text,
	c_reg_doc_numb text,
	c_date text,
	c_reg_doc_date text,
	c_inspector text
)
location (
	'gpfdist://10.30.104.107:8081/TAX_INSP.csv'
)
format 'csv' (header delimiter '^');


create external table tax_inspect(
	id text,
	c_name text,
	c_city text,
	c_district text,
	c_num text
)
location (
	'gpfdist://10.30.104.107:8081/TAX_INSPECT.csv'
)
format 'csv' (header delimiter '^');


create external table region(
	id text,
	c_name text
)
location (
	'gpfdist://10.30.104.107:8081/REGION.csv'
)
format 'csv' (header delimiter '^');


create external table ins_restrict(
	id text,
	c_code text,
	c_name text
)
location (
	'gpfdist://10.30.104.107:8081/INS_RESTRICT.csv'
)
format 'csv' (header delimiter ',');


create external table st_client(
	id text,
	c_kind_limit text,
	collection_id text,
	c_date_begin text,
	c_date_end text,
	c_reason text,
	c_lim_num text,
	c_dop_info text,
	c_lim_date text
)
location (
	'gpfdist://10.30.104.107:8081/ST_CLIENT.csv'
)
format 'csv' (header delimiter ',');


create external table okved_ref(
	id text,
	collection_id text,
	c_value text
)
location (
	'gpfdist://10.30.104.107:8081/OKVED_REF.csv'
)
format 'csv' (header delimiter ',');


create external table okved(
	id text,
	c_code text
)
location (
	'gpfdist://10.30.104.107:8081/OKVED.csv'
)
format 'csv' (header delimiter ',');


create external table cl_bank(
	id text,
	c_swift_c text,
	class_id text
)
location (
	'gpfdist://10.30.104.107:8081/CL_BANK.csv'
)
format 'csv' (header delimiter ',');


create external table cl_group(
	id text,
	c_name text,
	c_code text
)
location (
	'gpfdist://10.30.104.107:8081/CL_GROUP.csv'
)
format 'csv' (header delimiter ',');


create external table cl_categories(
	id text,
	c_category text,
	collection_id text,
	c_date_end text,
	c_date_begin text
)
location (
	'gpfdist://10.30.104.107:8081/CL_CATEGORIES.csv'
)
format 'csv' (header delimiter '^');


create external table cl_org(
	id text,
	c_business text,
	c_date_liquid text
)
location (
	'gpfdist://10.30.104.107:8081/CL_ORG.csv'
)
format 'csv' (header delimiter '^');


create external table country(
	id text,
	c_name text,
	c_code text,
	c_end_date text,
	c_begin_date text
)
location (
	'gpfdist://10.30.104.107:8081/COUNTRY.csv'
)
format 'csv' (header delimiter ',');


create external table cl_bank_n(
	id text,
	c_ks text,
	c_bic text,
	c_reg_num text,
	c_ks_old text
)
location (
	'gpfdist://10.30.104.107:8081/CL_BANK_N.csv'
)
format 'csv' (header delimiter '^');


create external table form_property(
	id text,
	c_short_name text,
	c_code text,
	c_name text
)
location (
	'gpfdist://10.30.104.107:8081/FORM_PROPERTY.csv'
)
format 'csv' (header delimiter '^');


create external table ownership_type(
	id text,
	c_short_name text,
	c_name text
)
location (
	'gpfdist://10.30.104.107:8081/OWNERSHIP_TYPE.csv'
)
format 'csv' (header delimiter '^');


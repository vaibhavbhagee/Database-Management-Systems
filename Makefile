db = sudo -u postgres psql 
db_name = test
cur_dir = $(shell pwd)
sql_files_dir = $(cur_dir)/sql_files

create_tables:
	$(db) -d $(db_name) -a -f $(sql_files_dir)/create_tables.sql

load_tables:
	$(db) -d $(db_name) -a -f $(sql_files_dir)/load_tables.sql

view_tables:
	$(db) -d $(db_name) -a -f $(sql_files_dir)/view_tables.sql

delete_tables:
	$(db) -d $(db_name) -a -f $(sql_files_dir)/delete_tables.sql

run:
	$(db) -d $(db_name) -a -f $(sql_files_dir)/queries.sql

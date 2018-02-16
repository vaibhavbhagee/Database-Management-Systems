db = sudo -u postgres psql 
db_name = test
cur_dir = $(shell pwd)

create_tables:
	$(db) -d $(db_name) -a -f create_tables.sql

load_tables:
	$(db) -d $(db_name) -a -f load_tables.sql

view_tables:
	$(db) -d $(db_name) -a -f view_tables.sql

delete_tables:
	$(db) -d $(db_name) -a -f delete_tables.sql

run:
	$(db) -d $(db_name) -a -f queries.sql
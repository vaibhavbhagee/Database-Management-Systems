create_table:
	sudo -u postgres psql -d test -a -f design.sql

insert:
	sudo -u postgres psql -d test -a -f queries.sql

delete_table:
	sudo -u postgres psql -d test -a -f delete_tables.sql	

view:
	sudo -u postgres psql -d test -a -f view_table_details.sql

test:
	sudo -u postgres psql -d test -a -f test_queries.sql
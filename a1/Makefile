create_table:
	sudo -u postgres psql -d test -a -f design.sql

big:
	python data_generator/generator.py 707 false > big_queries.sql
	sudo -u postgres psql -d test -a -f big_queries.sql

big_bulk:
	sudo -u postgres psql -d test -a -f copy_to.sql
	make delete_table
	make create_table
	sudo -u postgres psql -d test -a -f copy_from.sql

insert:
	sudo -u postgres psql -d test -a -f queries.sql

delete_table:
	sudo -u postgres psql -d test -a -f delete_tables.sql	

view:
	sudo -u postgres psql -d test -a -f view_table_details.sql

test:
	sudo -u postgres psql -d test -a -f test_queries.sql

clean:
	rm -rf big_queries.sql
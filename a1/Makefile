create_table:
	sudo -u postgres psql -d test -a -f design.sql

big:
	python data_generator/generator.py 10 false > big_queries.sql
	sudo -u postgres psql -d test -a -f big_queries.sql

big_bulk:
	python data_generator/generator.py 10 true > big_queries.sql
	sudo -u postgres psql -d test -a -f big_queries.sql

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
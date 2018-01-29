db = sudo -u postgres psql 
db_name = test
cur_dir = $(shell pwd)
data_gen = $(cur_dir)/data_generator
sql_scripts = $(cur_dir)/sql_files
num_entries = 707
bul_load = false
tmp_dir = /tmp
jdbc_dir = $(cur_dir)/jdbc

create_table:
	$(db) -d $(db_name) -a -f $(sql_scripts)/design.sql

big:
	python $(data_gen)/generator.py $(num_entries) $(bul_load) > $(sql_scripts)/big_queries.sql
	$(db) -d $(db_name) -a -f $(sql_scripts)/big_queries.sql

bulk_load:
	$(db) -d $(db_name) -a -f $(sql_scripts)/copy_to.sql
	make delete_table
	make create_table
	$(db) -d $(db_name) -a -f $(sql_scripts)/copy_from.sql

insert:
	$(db) -d $(db_name) -a -f $(sql_scripts)/queries.sql

delete_table:
	$(db) -d $(db_name) -a -f $(sql_scripts)/delete_tables.sql	

view:
	$(db) -d $(db_name) -a -f $(sql_scripts)/view_table_details.sql

test:
	$(db) -d $(db_name) -a -f $(sql_scripts)/test_queries.sql

jdbc_tgt:
	javac $(jdbc_dir)/PostgreSQLJDBC.java
	make delete_table
	cd $(jdbc_dir)/; \
	java -classpath postgresql-42.2.1.jar:. PostgreSQLJDBC; \
	cd $(cur_dir)/

clean:
	rm -rf $(sql_scripts)/big_queries.sql
	rm -rf $(jdbc_dir)/*.class
	sudo rm -rf $(tmp_dir)/course.csv
	sudo rm -rf $(tmp_dir)/teacher.csv
	sudo rm -rf $(tmp_dir)/student.csv
	sudo rm -rf $(tmp_dir)/teaches.csv
	sudo rm -rf $(tmp_dir)/registers.csv
	sudo rm -rf $(tmp_dir)/section.csv
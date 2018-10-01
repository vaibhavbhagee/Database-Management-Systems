# Assignment 1 - Database Design

* Instructions for running the code

1. To run the tests corresponding to various data loading methods, follow the following steps in order:

	1. To create the tables, run: 
		* `make db_name=<name-of-database> create_table`

	1. To generate the large dataset (707 entries in each **course**, **teacher** and **student** table, 707x707 entries in **registers** and **teaches** table, 707x4 entries in **section** table), run: 
		* `make db_name=<name-of-database> big`

	1. To run the bulk load, run:
		* `make db_name=<name-of-database> bulk_load`

	1. To run jdbc, run:
		* `make db_name=<name-of-database> jdbc_tgt`

	1. To empty and delete the tables, run:
		* `make db_name=<name-of-database> delete_tables`

	1. To clean and restore the current directory to initial state, run:
		* `make db_name=<name-of-database> clean`

1. To inspect the content of tables at any point of time, run:
	* `make db_name=<name-of-database> view`

1. To run the tests, run:
	* `make db_name=<name-of-database> test`

1. The tests have been segmented based on checks (as mentioned in the comments in the **test_queries.sql** file in the **sql_files** folder). 
	* To run one segment of tests, the initial segment of *INSERT* statements and the statements corresponding to the segment of tests should be un-commented and other statements should be commented. 
	* This should be done after the tables have been created in the database.  

1. **NOTE:** The commands should be run from the directory containing the make file

1. **NOTE:** All the parameters are set in the make file and can be edited as per need
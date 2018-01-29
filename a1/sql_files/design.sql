CREATE TABLE student(
	student_id varchar(50) PRIMARY KEY,
	name varchar(50)
);

CREATE TABLE course(
	course_id varchar(50) PRIMARY KEY,
	name varchar(50)
);

CREATE TABLE teacher(
	teacher_id varchar(50) PRIMARY KEY,
	name varchar(50)
);

CREATE TABLE registers(
	student_id varchar(50) REFERENCES student(student_id) ON DELETE CASCADE,
	course_id varchar(50) REFERENCES course(course_id) ON DELETE CASCADE,
	PRIMARY KEY (student_id, course_id)
);

CREATE TABLE teaches(
	course_id varchar(50) REFERENCES course(course_id) ON DELETE CASCADE,
	teacher_id varchar(50) REFERENCES teacher(teacher_id) ON DELETE CASCADE,
	PRIMARY KEY (teacher_id, course_id)	
);

CREATE TABLE section(
	section_number varchar(1) CHECK (section_number IN ('A','B','C','D')),
	course_id varchar(50) REFERENCES course(course_id) ON DELETE CASCADE,
	PRIMARY KEY (course_id, section_number)
);

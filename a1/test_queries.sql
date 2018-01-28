-- Causes no change
-- DELETE FROM section;
-- DELETE FROM registers;
-- DELETE FROM teaches;

-- Checks Referential integrity
-- DELETE FROM course;
-- DELETE FROM teacher;
-- DELETE FROM student;

-- Checks for section
-- INSERT INTO section VALUES ('A','IRY743');
-- INSERT INTO section VALUES ('E','IRY743');
-- INSERT INTO section VALUES ('A','AAAAAA');

-- Checks for teaches
-- INSERT INTO teaches VALUES ('URG062','T9');
-- INSERT INTO teaches VALUES ('URG062','T10');
-- INSERT INTO teaches VALUES ('AAAAAA','T9');

-- Checks for registers
-- INSERT INTO registers VALUES ('S8','QCM751');
-- INSERT INTO registers VALUES ('S8','AAAAAA');
-- INSERT INTO registers VALUES ('S10','QCM751');

-- Checks for DELETE statements
-- DELETE FROM course WHERE course_id = 'IRY743';

-- DELETE FROM teacher WHERE teacher_id = 'T9';
-- INSERT INTO teaches VALUES ('IRY743','T9');

-- DELETE FROM student WHERE student_id = 'S8';
-- INSERT INTO registers VALUES ('S8','IRY743');

-- Checks for UPDATE statements
UPDATE teacher SET teacher_id = 'T10' WHERE teacher_id = 'T9';
-- TODO: Check for update cascade
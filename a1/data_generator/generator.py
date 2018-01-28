import random
import string
import pprint
import itertools
import sys

bulk = False

if sys.argv[2] == "true":
    bulk = True

with open('/usr/share/dict/words') as fin:
    WORD_LIST = map(lambda x: x.strip().translate(None, string.punctuation), list(fin))

def generate_random_course(number=1000):
    '''
    input: an integer that lists the number of courses to be generated
    output: returns a list of JSONs with in the format { course_id: <id>, course_title: <title> }
    '''
    course_code_set = set()
    while len(course_code_set) < number:
        prefix_code = ''.join([random.choice(string.ascii_uppercase) for _ in range(3)])
        suffix_code = ''.join([random.choice(string.digits) for _ in range(3)])
        code = prefix_code + suffix_code
        course_code_set.add(code)
    course_name_set = set()
    while len(course_name_set) < number:
        course_name = 'Introduction to ' + random.choice(WORD_LIST)
        course_name_set.add(course_name)
    courses = list(zip(list(course_code_set), list(course_name_set)))
    result = [{'course_id': code, 'name': title} for code, title in courses]
    return result

def generate_random_teacher(number=1000):
    ''' 
    Returns a list of teachers. 
    '''
    name_set = set()
    while len(name_set) < number:
        first_name = random.choice(['Jethalal', 'Mary', 'Ram', 'Muhammed', 'Hirohito', 'John', 'Vladimir', 'Nadezhda'])
        middle_name = random.choice(WORD_LIST)
        last_name = random.choice(['Poppins', 'Singh', 'Kumar', 'Khan', 'Mizuhara', 'Kalashnikov', 'Gadot'])
        person_name = '{} {} {}'.format(first_name, middle_name, last_name)
        name_set.add(person_name)
    people = [{'teacher_id': 'T{}'.format(code), 'name': name} for code, name in zip(range(len(name_set)), list(name_set))]
    return people

def generate_random_student(number=1000):
    ''' 
    Returns a list of students 
    '''
    name_set = set()
    while len(name_set) < number:
        first_name = random.choice(['Tipendra', 'Pankaj', 'Sonalika', 'Gurucharan', 'Gulab', 'Natwarlal', 'Bageshwar', 'Uvuvwevwevwe'])
        middle_name = random.choice(WORD_LIST)
        last_name = random.choice(['Gada', 'Sahay', 'Bhide', 'Sodhi', 'Kumar', 'Undhaiwala', 'Ossas'])
        person_name = '{} {} {}'.format(first_name, middle_name, last_name)
        name_set.add(person_name)
    people = [{'student_id': 'S{}'.format(code), 'name': name} for code, name in zip(range(len(name_set)), list(name_set))]
    return people

def gen_queries(entity_list=[], table_name=''):
    '''
    Returns a list of SQL queries from a list of input JSON values
    '''
    table_to_col = {
        'teacher': 'teacher_id',
        'course': 'course_id',
        'student': 'student_id'
    }
    query_list = []
    for entity in entity_list:
        query_list.append('''INSERT INTO {} VALUES ('{}','{}');'''.format(table_name, entity[table_to_col[table_name]], entity['name']))

    return query_list

def gen_queries_single(entity_list=[], table_name=''):
    '''
    Returns a list of SQL queries from a list of input JSON values
    '''
    table_to_col = {
        'teacher': 'teacher_id',
        'course': 'course_id',
        'student': 'student_id'
    }
    query_list = []
    initial = '''INSERT INTO {} VALUES'''.format(table_name)
    for entity in entity_list:
        initial += ''' ('{}','{}'),'''.format(entity[table_to_col[table_name]], entity['name'])

    if bulk:
        query_list.append('''COPY ({} RETURNING *) TO STDOUT;'''.format(initial[:-1]))
    else:
        query_list.append('''{};'''.format(initial[:-1]))

    return query_list

def gen_relation_queries(teacher_list, student_list, course_list):
    '''
    Return the queries for the relations registers, teaches and weak entity set section
    '''
    reg_list = itertools.product(student_list, course_list)
    teach_list = itertools.product(teacher_list, course_list)
    section_list = itertools.product(['A', 'B', 'C', 'D'], course_list)
    query_list = []

    for (student, course) in reg_list:
        query_list.append('''INSERT INTO {} VALUES ('{}','{}');'''.format('registers', student['student_id'], course['course_id']))        

    for (teacher, course) in teach_list:
        query_list.append('''INSERT INTO {} VALUES ('{}','{}');'''.format('teaches', course['course_id'], teacher['teacher_id'])) 

    for (section_num, course) in section_list:
        query_list.append('''INSERT INTO {} VALUES ('{}','{}');'''.format('section', section_num, course['course_id']))        

    return query_list

def gen_relation_queries_single(teacher_list, student_list, course_list):
    '''
    Return the queries for the relations registers, teaches and weak entity set section
    '''
    reg_list = itertools.product(student_list, course_list)
    teach_list = itertools.product(teacher_list, course_list)
    section_list = itertools.product(['A', 'B', 'C', 'D'], course_list)
    query_list = []

    reg_initial = '''INSERT INTO {} VALUES'''.format('registers')

    for (student, course) in reg_list:
        reg_initial += ''' ('{}','{}'),'''.format(student['student_id'], course['course_id'])

    if bulk:
        query_list.append('''COPY ({} RETURNING *) TO STDOUT;'''.format(reg_initial[:-1]))
    else:
        query_list.append('''{};'''.format(reg_initial[:-1]))

    teach_initial = '''INSERT INTO {} VALUES'''.format('teaches')

    for (teacher, course) in teach_list:
        teach_initial += ''' ('{}','{}'),'''.format(course['course_id'], teacher['teacher_id'])

    if bulk:
        query_list.append('''COPY ({} RETURNING *) TO STDOUT;'''.format(teach_initial[:-1]))
    else:
        query_list.append('''{};'''.format(teach_initial[:-1]))

    section_initial = '''INSERT INTO {} VALUES'''.format('section')

    for (section_num, course) in section_list:
        section_initial += ''' ('{}','{}'),'''.format(section_num, course['course_id'])

    if bulk:
        query_list.append('''COPY ({} RETURNING *) TO STDOUT;'''.format(section_initial[:-1]))
    else:
        query_list.append('''{};'''.format(section_initial[:-1]))

    return query_list

if __name__ == '__main__':

    num_records = int(sys.argv[1])

    table_list = {
        'student' : generate_random_student, 
        'teacher' : generate_random_teacher, 
        'course' : generate_random_course
    }

    student_list = table_list['student']()[:num_records]
    teacher_list = table_list['teacher']()[:num_records]
    course_list = table_list['course']()[:num_records]

    query_list = gen_queries_single(student_list, 'student')
    query_list += gen_queries_single(teacher_list, 'teacher')
    query_list += gen_queries_single(course_list, 'course')
    query_list += gen_relation_queries_single(teacher_list, student_list, course_list)

    print('\\timing')

    for j in query_list:
        print( j )


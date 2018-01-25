with open("/usr/share/dict/words") as fin:
    WORD_LIST = map(lambda x: x.strip(), list(fin))

import random
import string
import pprint

def generate_random_course(number=1000):
    """
    input: an integer that lists the number of courses to be generated
    output: returns a list of JSONs with in the format { course_id: <id>, course_title: <title> }
    """
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
    result = [{'course_id': code, 'course_title': title} for code, title in courses]
    return result

def generate_random_person(number=1000):
    """ Returns a list of person objects which can be used for students and teachers. """
    name_set = set()
    while len(name_set) < number:
        first_name = random.choice(['Jethalal', 'Mary', 'Ram', 'Muhammed', 'Hirohito', 'John', 'Vladimir', 'Nadezhda'])
        middle_name = random.choice(WORD_LIST)
        last_name = random.choice(['Poppins', 'Singh', 'Kumar', 'Khan', 'Mizuhara', 'Kalashnikov', 'Gadot'])
        person_name = '{} {} {}'.format(first_name, middle_name, last_name)
        name_set.add(person_name)
    people = [{'teacher_id': code, 'name': name} for code, name in zip(range(len(name_set)), list(name_set))]
    return people

if __name__ == '__main__':
    pprint.pprint(generate_random_course())
    pprint.pprint(generate_random_person())


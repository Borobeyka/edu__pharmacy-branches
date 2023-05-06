from dotmap import DotMap
from werkzeug.security import generate_password_hash, check_password_hash
from psycopg2.extras import RealDictCursor, RealDictRow


def convert(data):
    a = []
    if isinstance(data, RealDictRow):
        return DotMap(data)
    for item in data:
        a.append(DotMap(item))
    return a

class DB():
    def __init__(self, db):
        self.db = db
        self.cursor = db.cursor(cursor_factory=RealDictCursor)

    def get_employees_by_branch_id(self, branch_id):
        self.cursor.execute("SELECT * FROM get_employees_by_branch_id(%s)", (branch_id,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return [DotMap(response)]

    def get_branche_by_id(self, branch_id):
        self.cursor.execute("SELECT * FROM branches WHERE id=%s", (branch_id,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

    def get_branches(self):
        self.cursor.execute("SELECT * FROM branches")
        response = self.cursor.fetchone()
        if not response:
            return False
        return [DotMap(response)]

    def get_employee_by_login(self, data):
        self.cursor.execute("SELECT * FROM employees WHERE login=%s", (data.login.data,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

    def get_employee(self, employee_id):
        self.cursor.execute("SELECT * FROM employees WHERE id=%s", (employee_id,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

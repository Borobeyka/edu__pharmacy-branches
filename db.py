from dotmap import DotMap
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

    def get_orders_details_by_id(self, order_id):
        self.cursor.execute("SELECT * FROM get_orders_details_by_id(%s)", (order_id,))
        response = self.cursor.fetchall()
        if not response:
            return False
        return convert(response)

    def get_order_by_id(self, order_id):
        self.cursor.execute("SELECT * FROM get_order_by_id(%s)", (order_id,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

    def create_orders_details(self, item):
        self.cursor.execute("CALL create_orders_details(%s, %s, %s)", (item.order_id, item.medicament_id, item.count))
        self.db.commit()

    def create_order(self, data):
        self.cursor.execute("SELECT * FROM create_order(%s, %s)", (data.branch_id, data.employee_id))
        self.db.commit()
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

    def medicament_update(self, data):
        self.cursor.execute("UPDATE medicaments SET title=%s, description=%s, category_id=%s, manufacturer_id=%s, image_url=%s, price=%s WHERE id=%s",
                            (data.title, data.description, data.category_id, data.manufacturer_id, data.image_url, data.price, data.id))
        self.db.commit()

    def medicament_delete_by_id(self, medicament_id):
        self.cursor.execute('''
            BEGIN;
                DELETE FROM medicaments WHERE id = %s;
            COMMIT;
        ''', (medicament_id,))
        self.db.commit()

    def medicament_add(self, data):
        self.cursor.execute("SELECT * FROM medicament_add(%s, %s, %s, %s, %s, %s)",
                            (data.title, data.description, data.category_id, data.manufacturer_id, data.image_url, data.price))
        self.db.commit()

    def get_all_orders(self):
        self.cursor.execute("SELECT * FROM get_all_orders")
        response = self.cursor.fetchall()
        if not response:
            return False
        return convert(response)

    def get_manufacturer_by_id(self, manufacturer_id):
        self.cursor.execute("SELECT * FROM get_manufacturer_by_id(%s)", (manufacturer_id,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

    def get_medicament_by_id(self, medicament_id):
        self.cursor.execute("SELECT * FROM get_medicament_by_id(%s)", (medicament_id,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

    def get_filtered_medicaments(self, data):
        self.cursor.execute("SELECT * FROM get_filtered_medicaments(%s, %s, %s)",
                            (data.title, data.category_id, data.manufacturer_id))
        response = self.cursor.fetchall()
        if not response:
            return False
        return convert(response)

    def get_all_categories(self):
        self.cursor.execute("SELECT * FROM categories")
        response = self.cursor.fetchall()
        if not response:
            return False
        return convert(response)

    def get_all_manufacturers(self):
        self.cursor.execute("SELECT * FROM manufacturers")
        response = self.cursor.fetchall()
        if not response:
            return False
        return convert(response)

    def get_employees_by_branch_id(self, branch_id):
        self.cursor.execute("SELECT * FROM get_employees_by_branch_id(%s)", (branch_id,))
        response = self.cursor.fetchall()
        if not response:
            return False
        return convert(response)

    def get_branch_by_id(self, branch_id):
        self.cursor.execute("SELECT * FROM branches WHERE id=%s", (branch_id,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

    def get_branches(self):
        self.cursor.execute("SELECT * FROM branches")
        response = self.cursor.fetchall()
        if not response:
            return False
        return convert(response)

    def get_employee_by_login(self, data):
        self.cursor.execute("SELECT * FROM employees WHERE login=%s", (data.login.data,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

    def get_employee(self, employee_id):
        self.cursor.execute("SELECT e.*, p.title position_title FROM employees e \
                            LEFT JOIN positions p ON p.id = e.position_id WHERE e.id=%s", (employee_id,))
        response = self.cursor.fetchone()
        if not response:
            return False
        return convert(response)

from flask_login import UserMixin


class UserLogin(UserMixin):
    def fromDB(self, employee_id, db):
        self.user = db.get_employee(employee_id)
        return self

    def create(self, user):
        self.user = user
        return self

    def get_id(self):
        return str(self.user.id)

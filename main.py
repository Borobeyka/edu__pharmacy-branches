import psycopg2
from dotmap import DotMap
from werkzeug.security import generate_password_hash, check_password_hash
from flask import Flask, flash, g, redirect, render_template, request, url_for
from flask_login import LoginManager, current_user, login_required, login_user, logout_user
from flask_menu import Menu, register_menu

from db import DB
from forms.forms import *
from user_login import UserLogin

# print(generate_password_hash("123456"))

app = Flask(__name__)
app.secret_key = "9d3fc4c15037cf54e9e6ca948d99dda7f1823d1d"
app.jinja_env.trim_blocks = True
login_manager = LoginManager(app=app)
login_manager.login_view = "employee_auth"
login_manager.login_message = "Для доступа требуется авторизация"
login_manager.login_message_category = "danger"
Menu(app=app)


@app.route("/", methods=["POST", "GET"])
@register_menu(app, ".", "Главная", order=0)
@login_required
def index():
    return render_template("medicaments/index.htm")


@app.route("/employee/auth", methods=["POST", "GET"])
def employee_auth():
    if current_user.is_authenticated:
        return redirect(url_for("index"))
    form = FormEmployeeAuth()
    if form.validate_on_submit():
        employee = db.get_employee_by_login(DotMap({"login": form.login}))
        if employee != False and check_password_hash(employee.password, form.pswd.data):
            user_login = UserLogin().create(employee)
            login_user(user_login)
            return redirect(request.args.get("next") or url_for("index"))
        form.login.errors.append("Логин или пароль введен неверно")
    return render_template("employee/auth.htm", form=form)

@app.route("/employee/logout")
def employee_logout():
    if current_user.is_authenticated:
        logout_user()
        flash("Вы вышли из учетной записи", "success")
    return redirect(url_for("employee_auth"))


@app.route("/branches", methods=["POST", "GET"])
@register_menu(app, ".branches", "Филиалы", order=1)
@login_required
def branches():
    branches = db.get_branches()
    return render_template("branches/index.htm", branches=branches)


@app.route("/branches/<int:branch_id>", methods=["POST", "GET"])
@login_required
def branches_show(branch_id):
    branche = db.get_branche_by_id(branch_id)
    employees = db.get_employees_by_branch_id(branch_id)
    if not branche:
        redirect(url_for("branches"))
    return render_template(
        "branches/show.htm",
        branche=branche,
        employees=employees
    )


@app.context_processor
def context_processor():
    if current_user.is_authenticated:
        return dict(user=current_user.user)
    return dict()


db = None
@app.before_request
def before_request():
    global db
    db = DB(get_db())


@app.teardown_appcontext
def close_db(error):
    if hasattr(g, "link_db"):
        g.link_db.close()


def connect_db():
    from dotenv import dotenv_values
    config = dotenv_values(".env")
    return psycopg2.connect(config.get("DATABASE_DSN"))


def get_db():
    if not hasattr(g, "link_db"):
        g.link_db = connect_db()
    return g.link_db


@login_manager.user_loader
def load_user(employee_id):
    return UserLogin().fromDB(employee_id, db)


if __name__ == "__main__":
    app.run(debug=True)

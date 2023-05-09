import psycopg2
from dotmap import DotMap
from werkzeug.security import generate_password_hash, check_password_hash
from flask import Flask, flash, g, redirect, render_template, request, url_for
from flask_login import LoginManager, current_user, login_required, login_user, logout_user
from flask_menu import Menu, register_menu

from db import DB
from forms.forms import *
from user_login import UserLogin

print(generate_password_hash("randomkey"))

app = Flask(__name__)
app.secret_key = "iMjwrw4MXLYWkQxZ$13c482e5ca9f68d8979845335c41d252256"
app.jinja_env.trim_blocks = True
login_manager = LoginManager(app=app)
login_manager.login_view = "employee_auth"
login_manager.login_message = "Для доступа требуется авторизация"
login_manager.login_message_category = "danger"
Menu(app=app)


@app.route("/", methods=["POST", "GET"])
@register_menu(app, ".", "Главная", order=1)
@login_required
def index():
    categories = db.get_all_categories()
    manufacturers = db.get_all_manufacturers()
    search_form = FormMedicamentsSearch(categories, manufacturers)
    values = DotMap({
        "title": search_form.title.data if search_form.title.data is not None and len(search_form.title.data) > 0 else None,
        "category_id": search_form.category_id.data if search_form.category_id.data != "-1" else None,
        "manufacturer_id": search_form.manufacturer_id.data if search_form.manufacturer_id.data != "-1" else None,
    })
    medicaments = db.get_filtered_medicaments(values)
    return render_template(
        "medicaments/index.htm",
        search_form=search_form,
        medicaments=medicaments
    )


order_items = []
@app.route("/order/add", methods=["POST", "GET"])
@register_menu(app, ".orders_add", "Новая продажа", order=3)
@login_required
def orders_add():
    global order_items
    form = FormOrderAdd()
    if request.args.get("medicament_id"):
        id = int(request.args.get("medicament_id"))
        flag = False
        for order_item in order_items:
            if order_item.item.id == id:
                if not request.args.get("minus"):
                    order_item.count += 1
                else:
                    order_item.count -= 1
                    if order_item.count == 0:
                        order_items.remove(order_item)
                flag = True
                break
        if not flag:
            order_items.append(DotMap({
                "item": db.get_medicament_by_id(id),
                "count": 1
            }))
        return redirect(url_for("orders_add"))
    if form.validate_on_submit() and request.method == "POST":
        data = DotMap({
            "branch_id": current_user.user.branch_id,
            "employee_id": current_user.user.id
        })
        new_order = db.create_order(data)
        for order_item in order_items:
            item = DotMap({
                "order_id": new_order.new_id,
                "medicament_id": order_item.item.id,
                "count": order_item.count
            })
            db.create_orders_details(item)
        return redirect(url_for(
            "orders_create_reset",
            next=url_for("orders")
        ))
    return render_template(
        "orders/add.htm",
        order_items=order_items,
        form=form
    )

@app.route("/orders/create/reset", methods=["POST", "GET"])
@login_required
def orders_create_reset():
    global order_items
    order_items = []
    return redirect(request.args.get("next") or url_for("index"))


@app.route("/orders/<int:order_id>", methods=["POST", "GET"])
@login_required
def orders_show(order_id):
    order = db.get_order_by_id(order_id)
    if not order:
        return redirect(url_for("orders"))
    order_details = db.get_orders_details_by_id(order_id)
    return render_template("orders/show.htm", order=order, order_details=order_details)


@app.route("/orders", methods=["POST", "GET"])
@register_menu(app, ".orders", "Продажи", order=1)
@login_required
def orders():
    orders = db.get_all_orders()
    return render_template("orders/index.htm", orders=orders)


@app.route("/medicaments/<int:medicament_id>", methods=["POST", "GET"])
@login_required
def medicaments_show(medicament_id):
    medicament = db.get_medicament_by_id(medicament_id)
    if not medicament:
        return redirect(url_for("index"))
    return render_template(
        "medicaments/show.htm",
        medicament=medicament
    )


@app.route("/medicaments/add", methods=["POST", "GET"])
@login_required
def medicaments_add():
    if current_user.user.position_id != 1:
        return redirect(url_for("index"))
    categories = db.get_all_categories()
    manufacturers = db.get_all_manufacturers()
    add_form = FormMedicamentsAdd(categories, manufacturers)
    if add_form.validate_on_submit():
        data = DotMap({
            "title": add_form.title.data,
            "description": add_form.description.data,
            "category_id": add_form.category_id.data,
            "manufacturer_id": add_form.manufacturer_id.data,
            "image_url": add_form.image_url.data,
            "price": add_form.price.data,
        })
        db.medicament_add(data)
        return redirect(url_for("index"))
    return render_template("medicaments/add.htm", add_form=add_form)


@app.route("/medicaments/delete/<int:medicament_id>", methods=["POST", "GET"])
@login_required
def medicaments_delete(medicament_id):
    if current_user.user.position_id != 1:
        return redirect(url_for("index"))
    db.medicament_delete_by_id(medicament_id)
    return redirect(url_for("index"))


@app.route("/medicaments/edit/<int:medicament_id>", methods=["POST", "GET"])
@login_required
def medicaments_edit(medicament_id):
    if current_user.user.position_id != 1:
        return redirect(url_for("index"))
    medicament = db.get_medicament_by_id(medicament_id)
    if not medicament:
        return redirect(url_for("index"))
    categories = db.get_all_categories()
    manufacturers = db.get_all_manufacturers()
    edit_form = FormMedicamentsEdit(categories, manufacturers, medicament)
    if edit_form.validate_on_submit():
        data = DotMap({
            "id": medicament_id,
            "title": edit_form.title.data,
            "description": edit_form.description.data,
            "category_id": edit_form.category_id.data,
            "manufacturer_id": edit_form.manufacturer_id.data,
            "image_url": edit_form.image_url.data,
            "price": edit_form.price.data,
        })
        db.medicament_update(data)
        return redirect(url_for("medicaments_show", medicament_id=medicament_id))
    return render_template("medicaments/edit.htm", medicament=medicament, edit_form=edit_form)


@app.route("/manufacturer/<int:manufacturer_id>", methods=["POST", "GET"])
@login_required
def manufacturers_show(manufacturer_id):
    manufacturer = db.get_manufacturer_by_id(manufacturer_id)
    if not manufacturer:
        return redirect(url_for("index"))
    return render_template(
        "manufacturers/index.htm",
        manufacturer=manufacturer
    )


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
@register_menu(app, ".branches", "Филиалы", order=2)
@login_required
def branches():
    branches = db.get_branches()
    return render_template("branches/index.htm", branches=branches)


@app.route("/branches/<int:branch_id>", methods=["POST", "GET"])
@login_required
def branches_show(branch_id):
    branch = db.get_branch_by_id(branch_id)
    employees = db.get_employees_by_branch_id(branch_id)
    if not branch:
        redirect(url_for("branches"))
    return render_template(
        "branches/show.htm",
        branch=branch,
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

from flask_wtf import FlaskForm
from wtforms import SubmitField, SelectField, StringField

def FormMedicamentsSearch(categories, manufacturers):
    class _FormMedicamentsSearch(FlaskForm):
        categories_list = [(-1, "Не выбрано")] + \
            [(category.id, category.title) for category in categories]
        manufacturers_list = [(-1, "Не выбрано")] + \
            [(manufacturer.id, manufacturer.title) for manufacturer in manufacturers]
        title = StringField("Название или описание")
        category_id = SelectField("Категория", choices=categories_list)
        manufacturer_id = SelectField("Производитель", choices=manufacturers_list)
        submit = SubmitField("Применить")
    return _FormMedicamentsSearch()

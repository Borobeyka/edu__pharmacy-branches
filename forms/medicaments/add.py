from flask_wtf import FlaskForm
from wtforms import SubmitField, SelectField, StringField, IntegerField
from wtforms.validators import NumberRange

def FormMedicamentsAdd(categories, manufacturers):
    class _FormMedicamentsAdd(FlaskForm):
        categories_list = [(category.id, category.title) for category in categories]
        manufacturers_list = [(manufacturer.id, manufacturer.title) for manufacturer in manufacturers]
        title = StringField("Введите название:")
        description = StringField("Введите описание:")
        category_id = SelectField("Категория:", choices=categories_list)
        manufacturer_id = SelectField("Производитель:", choices=manufacturers_list)
        image_url = StringField("Ссылка на изображение:")
        price = IntegerField("Стоимость (₽)", default=0, validators=[NumberRange(min=0)])
        submit = SubmitField("Добавить препарат")
    return _FormMedicamentsAdd()

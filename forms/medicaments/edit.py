from flask_wtf import FlaskForm
from wtforms.validators import NumberRange
from wtforms import SubmitField, SelectField, StringField, IntegerField, TextAreaField

def FormMedicamentsEdit(categories, manufacturers, medicament):
    class _FormMedicamentsEdit(FlaskForm):
        categories_list = [(category.id, category.title) for category in categories]
        manufacturers_list = [(manufacturer.id, manufacturer.title) for manufacturer in manufacturers]
        title = StringField("Название:", default=medicament.title)
        description = TextAreaField("Описание:", default=medicament.description, render_kw={"rows": "7"})
        category_id = SelectField("Категория:", choices=categories_list, default=medicament.category_id)
        manufacturer_id = SelectField("Производитель:", choices=manufacturers_list, default=medicament.manufacturer_id)
        image_url = StringField("Ссылка на изображение:", default=medicament.image_url)
        price = IntegerField("Стоимость (₽)", default=medicament.price, validators=[NumberRange(min=0)])
        submit = SubmitField("Сохранить изменения")
    return _FormMedicamentsEdit()

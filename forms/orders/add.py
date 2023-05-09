from flask_wtf import FlaskForm
from wtforms import SubmitField


class FormOrderAdd(FlaskForm):
    submit = SubmitField("Оформить продажу")

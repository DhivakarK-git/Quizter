# Generated by Django 3.1.7 on 2021-04-06 11:01

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('quizApp', '0018_auto_20210403_1723'),
    ]

    operations = [
        migrations.AlterField(
            model_name='takes',
            name='start_time',
            field=models.DateTimeField(null=True),
        ),
        migrations.AlterField(
            model_name='takes',
            name='times_taken',
            field=models.IntegerField(default=0, editable=False),
        ),
    ]

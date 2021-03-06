# Generated by Django 3.1.7 on 2021-03-13 04:59

from django.conf import settings
import django.core.validators
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Answer',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('answer_text', models.CharField(max_length=255)),
                ('correct', models.BooleanField(default=False)),
                ('feedback', models.CharField(max_length=255)),
                ('marks', models.IntegerField(default=1, validators=[django.core.validators.MinValueValidator(-250), django.core.validators.MaxValueValidator(250)])),
                ('a_image', models.ImageField(blank=True, default=None, null=True, upload_to='answer')),
            ],
        ),
        migrations.CreateModel(
            name='Clas',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('class_name', models.CharField(default='', max_length=255)),
            ],
        ),
        migrations.CreateModel(
            name='Course',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('course_id', models.CharField(default='', max_length=255)),
                ('course_name', models.CharField(default='', max_length=255)),
            ],
            options={
                'unique_together': {('course_id', 'course_name')},
            },
        ),
        migrations.CreateModel(
            name='Quiz',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('quiz_name', models.CharField(default='', max_length=255)),
                ('access_code', models.CharField(default='quizter', max_length=50)),
                ('start_time', models.DateTimeField()),
                ('end_time', models.DateTimeField()),
                ('publish_time', models.DateTimeField()),
                ('duration', models.IntegerField(validators=[django.core.validators.MinValueValidator(1), django.core.validators.MaxValueValidator(240)])),
                ('times_can_take', models.IntegerField(default=0)),
                ('linear', models.BooleanField(default=True)),
                ('shuffle', models.BooleanField(default=True)),
            ],
            options={
                'verbose_name_plural': 'Quizzes',
                'ordering': ['id'],
            },
        ),
        migrations.CreateModel(
            name='UserT',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('type', models.CharField(choices=[('student', 'Student'), ('faculty', 'Faculty'), ('admin', 'Admin')], default=None, max_length=10)),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Teaches',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('clas', models.ForeignKey(default=None, on_delete=django.db.models.deletion.CASCADE, to='quizApp.clas')),
                ('course', models.ForeignKey(default=None, on_delete=django.db.models.deletion.CASCADE, to='quizApp.course')),
                ('user', models.ForeignKey(default=None, on_delete=django.db.models.deletion.CASCADE, to='quizApp.usert')),
            ],
        ),
        migrations.CreateModel(
            name='Takes',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('times_taken', models.IntegerField(default=1, editable=False)),
                ('submission', models.CharField(max_length=30)),
                ('status', models.BooleanField(default=False)),
                ('quiz', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, related_name='takers', to='quizApp.quiz')),
                ('user', models.ForeignKey(default=None, on_delete=django.db.models.deletion.DO_NOTHING, to='quizApp.usert')),
            ],
        ),
        migrations.AddField(
            model_name='quiz',
            name='author',
            field=models.ForeignKey(default=None, on_delete=django.db.models.deletion.DO_NOTHING, to='quizApp.usert'),
        ),
        migrations.AddField(
            model_name='quiz',
            name='course',
            field=models.ForeignKey(default=None, on_delete=django.db.models.deletion.CASCADE, to='quizApp.course'),
        ),
        migrations.CreateModel(
            name='Question',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('question_text', models.CharField(default='', max_length=255)),
                ('question_type', models.CharField(choices=[('sca', 'Single Correct Answer'), ('mca', 'Multiple Correct Answer'), ('fitb', 'Fill In The Blanks'), ('short', 'Short Answer'), ('num', 'Numerical')], default=None, max_length=24)),
                ('question_mark', models.IntegerField(default=1, validators=[django.core.validators.MinValueValidator(1), django.core.validators.MaxValueValidator(500)])),
                ('q_image', models.ImageField(blank=True, default=None, null=True, upload_to='question')),
                ('quiz', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, related_name='questions', to='quizApp.quiz')),
            ],
            options={
                'ordering': ['id'],
            },
        ),
        migrations.CreateModel(
            name='Options',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('answer', models.ForeignKey(default=None, on_delete=django.db.models.deletion.DO_NOTHING, to='quizApp.answer')),
                ('question', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, related_name='options', to='quizApp.question')),
                ('user', models.ForeignKey(default=None, on_delete=django.db.models.deletion.DO_NOTHING, to='quizApp.usert')),
            ],
        ),
        migrations.CreateModel(
            name='Makes',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('status', models.BooleanField(default=False)),
                ('quiz', models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, related_name='makers', to='quizApp.quiz')),
                ('user', models.ForeignKey(default=None, on_delete=django.db.models.deletion.DO_NOTHING, to='quizApp.usert')),
            ],
        ),
        migrations.CreateModel(
            name='Belongs',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('clas', models.ForeignKey(default=None, on_delete=django.db.models.deletion.CASCADE, to='quizApp.clas')),
                ('user', models.ForeignKey(default=None, on_delete=django.db.models.deletion.CASCADE, to='quizApp.usert')),
            ],
        ),
        migrations.AddField(
            model_name='answer',
            name='question',
            field=models.ForeignKey(on_delete=django.db.models.deletion.DO_NOTHING, related_name='answers', to='quizApp.question'),
        ),
    ]

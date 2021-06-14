from django.test import TestCase
from datetime import datetime
from django.db import models,IntegrityError
from django.core.exceptions import ValidationError
from django.contrib.auth.models import User
from quizApp.models import UserT,Course,Clas,Teaches,Belongs,Quiz,Question,Answer,Options,Takes,Makes,Notification
from dateutil import tz

utc_tz= tz.gettz('UTC')
india_tz= tz.gettz('Asia/Kolkata')
date_string="2018-12-24T02:35:16-08:00"
utc = datetime.strptime(date_string[:date_string.rindex('-')], '%Y-%m-%dT%H:%M:%S')
utc = utc.replace(tzinfo=utc_tz)
ito = utc.astimezone(india_tz)
itoo = ito.replace(tzinfo=None)

class TestModels(TestCase):
    def setUp(self):
        user = User.objects.create(username='john',
                                 password='glassonion')
        self.user1=UserT.objects.create(user=user,type='student')
        self.user2 = User.objects.create(username='Ravi',
                                 password='deadfish')
        self.usert2=UserT.objects.create(user=self.user2,type='faculty')
        self.user3 = User.objects.create(username='Raju',
                                 password='deadonion')
        self.usera3=UserT.objects.create(user=self.user3,type='admin')

        self.id1=Course.objects.create(course_id='15CSE101',course_name="maths")
        self.id2=Course.objects.create(course_id='15CSE102',course_name="geography")
        self.clas1=Clas.objects.create(class_name="3C")
        self.teaches1=Teaches.objects.create(user=self.usert2,clas=self.clas1,course=self.id1)
        self.belongs=Belongs.objects.create(user=self.user1,clas=self.clas1)
        self.quiz1=Quiz.objects.create(quiz_name='Quiz1',access_code='super',start_time=ito,end_time=ito,publish_time=ito,duration=10,times_can_take=1,linear=True,shuffle=True,course=self.id1,marks=50)
        self.quiz2=Quiz.objects.create(quiz_name='Quiz2',access_code='super')
        self.makes=Makes.objects.create(quiz=self.quiz1,user=self.usert2)
        self.ques=Question.objects.create(quiz=self.quiz1,question_text='what',question_type='Num',question_mark=10,question_n_mark=-1)
        self.ans=Answer.objects.create(question=self.ques,answer_text='answer',correct=True,feedback='nice')
        self.option=Options.objects.create(question=self.ques,user=self.usert2,answer=self.ans)
        self.takes=(Takes.objects.create(pk=100,quiz=self.quiz1,user=self.user1,start_time=ito,times_taken=1,submission='yes',nemail=False))

    def test_usert_is_assigned_student_on_creation(self):
        self.assertEquals(str(self.user1),'john')
        self.assertEquals(self.user1.type,'student')

    def test_usert_is_assigned_admin_on_creation(self):
        self.assertEquals(str(self.usera3),'Raju')
        self.assertEquals(self.usera3.type,'admin')

    def test_usert_is_assigned_faculty_on_creation(self):
        self.assertEquals(str(self.usert2),'Ravi')
        self.assertEquals(self.usert2.type,'faculty')

    def test_usert_is_assigned_with_user_already_assigned_to_another_usert(self):
        with self.assertRaises(IntegrityError):
            UserT.objects.create(user=self.user2,type='admin')

    def test_course_is_assigned_to_course_id_on_creation(self):
        self.assertEquals((self.id1.course_id),'15CSE101')
        self.assertEquals(self.id1.course_name,'maths')

    def test_course_is_assigned_for_an_existing_course_id(self):
        with self.assertRaises(IntegrityError):
            Course.objects.create(course_id='15CSE101',course_name="science")

    def test_class_is_assigned_on_creation(self):
        self.assertEquals(str(self.clas1),'3C')

    def test_clas1_is_assigned_with_class_already_assigned_to_another_clas1(self):
        with self.assertRaises(IntegrityError):
            Clas.objects.create(class_name='3C')

    def test_teaches_is_assigned_for_a_user_valid_faculty_type(self):
        self.assertEquals(str(self.teaches1.user),'Ravi')
        self.assertEquals(self.teaches1.user.type,'faculty')
        self.assertEquals(str(self.teaches1.clas),'3C')
        self.assertEquals((self.teaches1.course.course_id),'15CSE101')
        self.assertEquals(self.teaches1.course.course_name,'maths')

    def test_teaches_is_assigned_for_a_user_invalid_faculty_type(self):
        t1=Teaches.objects.create(user=self.user1,clas=self.clas1,course=self.id1)
        with self.assertRaises(ValidationError):
            t1.clean()

    def test_teaches_is_assigned_with_clas_already_assigned_to_another(self):
        with self.assertRaises(IntegrityError):
            Teaches.objects.create(user=self.usert2,clas=self.clas1,course=self.id1)

    def test_course_is_assigned_with_teaches_already_assigned_to_another(self):
        with self.assertRaises(IntegrityError):
            Teaches.objects.create(user=self.usert2,course=self.id2)
    #course assigned to another teacher
    #admin part
    #vali-takes,makes

    def test_belongs_is_assigned_for_a_user_valid_student_type(self):
        self.assertEquals(str(self.belongs.user),'john')
        self.assertEquals(self.belongs.user.type,'student')
        self.assertEquals(str(self.belongs.clas),'3C')
    
    def test_belongs_is_assigned_for_a_user_invalid_student_type(self):
        t2=Belongs.objects.create(user=self.usert2,clas=self.clas1)
        with self.assertRaises(ValidationError):
            t2.clean()
    
    def test_takes_is_assigned_for_a_user_invalid_student_type(self):
        k=(Takes.objects.create(pk=101,quiz=self.quiz1,user=self.usert2,start_time=ito,times_taken=1,submission='yes',nemail=False))
        with self.assertRaises(ValidationError):
            k.clean()


    def test_makes_is_assigned_for_a_user_invalid_faculty_type(self):
        l=Makes.objects.create(quiz=self.quiz1,user=self.user1)
        with self.assertRaises(ValidationError):
            l.clean()


    def test_belongs_is_assigned_with_clas_already_assigned_to_another(self):
        with self.assertRaises(IntegrityError):
            Belongs.objects.create(user=self.user1,clas=self.clas1)
            #unique for belongs

    def test_quiz_is_assigned_on_creation(self):
        self.assertEquals(str(self.quiz1.quiz_name),'Quiz1')
        self.assertEquals(str(self.quiz1.access_code),'super')
        self.assertEquals(self.quiz1.start_time,ito)
        self.assertEquals(self.quiz1.end_time,ito)
        self.assertEquals(self.quiz1.publish_time,ito)
        self.assertEquals(self.quiz1.duration,10)
        self.assertEquals(self.quiz1.times_can_take,1)
        self.assertEquals(self.quiz1.linear,True)
        self.assertEquals(self.quiz1.shuffle,True)
        self.assertEquals((self.quiz1.course.course_id),'15CSE101')
        self.assertEquals(self.quiz1.marks,50)

    def test_quiz_is_assigned_on_creation_with_partial_info(self):
        self.assertEquals(str(self.quiz2.quiz_name),'Quiz2')
        self.assertEquals(str(self.quiz2.access_code),'super')

    def test_takes_is_assigned_on_creation(self):
        self.assertEquals(str(self.takes.user),'john')
        self.assertEquals(str(self.takes.quiz.quiz_name),'Quiz1')
        self.assertEquals(self.takes.quiz.start_time,ito)
        self.assertEquals(self.takes.times_taken,1)
        self.assertEquals(str(self.takes.submission),'yes')
        self.assertEquals(self.takes.nemail,False)

    def test_makes_is_assigned_on_creation(self):
        self.assertEquals(str(self.makes.user),'Ravi')
        self.assertEquals(str(self.makes.quiz.quiz_name),'Quiz1')

    def test_question_is_assigned_on_creation(self):
        self.assertEquals(str(self.ques.quiz.quiz_name),'Quiz1')
        self.assertEquals(str(self.ques.question_text),'what')
        self.assertEquals(str(self.ques.question_type),'Num')
        self.assertEquals(self.ques.question_mark,10)
        self.assertEquals(self.ques.question_n_mark,-1)

    def test_answer_is_assigned_on_creation(self):
        self.assertEquals(str(self.ans.question.question_text),'what')
        self.assertEquals(str(self.ans.answer_text),'answer')
        self.assertEquals(self.ans.correct,True)

    def test_option_is_assigned_on_creation(self):
        self.assertEquals(str(self.option.question.question_text),'what')
        self.assertEquals(str(self.option.user),'Ravi')
        self.assertEquals(str(self.option.answer.answer_text),'answer')

    def test_ans_is_assigned_with_question_already_assigned_to_another(self):
        with self.assertRaises(IntegrityError):
            Answer.objects.create(question=self.ques,answer_text='answer')

    def test_options_is_assigned_with_question_and_user_already_assigned_to_another(self):
        with self.assertRaises(IntegrityError):
            Options.objects.create(question=self.ques,user=self.usert2,answer=self.ans)

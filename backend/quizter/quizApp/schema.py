import graphene
from graphene_django.types import DjangoObjectType, ObjectType
from .models import Course,UserT,Clas,Teaches,Belongs,Quiz,Question,Answer,Options,Takes,Makes,Notification
from django.contrib.auth.models import User
import graphql_jwt
from django_graphene_permissions import permissions_checker
from django_graphene_permissions.permissions import IsAuthenticated
import datetime
import secrets
import string
from django.core.mail import send_mail
from django.utils import timezone


class CourseType(DjangoObjectType):
    class Meta:
        model = Course

class UserType(DjangoObjectType):
    class Meta:
        model = User

class UsetType(DjangoObjectType):
    class Meta:
        model = UserT

class ClassType(DjangoObjectType):
    class Meta:
        model = Clas

class TeachesType(DjangoObjectType):
    class Meta:
        model = Teaches

class BelongsType(DjangoObjectType):
    class Meta:
        model = Belongs


class QuestionType(DjangoObjectType):
    class Meta:
        model = Question

class QuizType(DjangoObjectType):
    class Meta:
        model = Quiz

    question = graphene.Field(QuestionType, id=graphene.Int())

    @permissions_checker([IsAuthenticated])
    def resolve_question(self, info, **kwargs):
        id = kwargs.get('id')

        if id is not None:
            return Question.objects.get(pk=id)
        return None


class AnswerType(DjangoObjectType):
    class Meta:
        model = Answer

class NotificationType(DjangoObjectType):
    class Meta:
        model = Notification

class OptionsType(DjangoObjectType):
    class Meta:
        model = Options

class TakesType(DjangoObjectType):
    class Meta:
        model = Takes

    quiz = graphene.Field(QuizType, id=graphene.Int())
    quizzes = graphene.List(QuizType)

    @permissions_checker([IsAuthenticated])
    def resolve_quiz(self, info, **kwargs):
        id = kwargs.get('id')
        if id is not None:
            return Quiz.objects.get(pk=id)
        return None

    @permissions_checker([IsAuthenticated])
    def resolve_quizzes(self, info, **kwargs):
        now=timezone.now()
        temp=Quiz.objects.all()
        result=[]
        for i in range(len(temp)):
            if(temp[i].end_time>=now or now+datetime.timedelta(days=7)>=temp[i].end_time):
                result.append(temp[i])
        return result

class MakesType(DjangoObjectType):
    class Meta:
        model = Makes

    quiz = graphene.Field(QuizType, id=graphene.Int())
    quizzes = graphene.List(QuizType)

    @permissions_checker([IsAuthenticated])
    def resolve_quiz(self, info, **kwargs):
        id = kwargs.get('id')
        if id is not None:
            return Quiz.objects.get(pk=id)
        return None

    @permissions_checker([IsAuthenticated])
    def resolve_quizzes(self, info, **kwargs):
        return Quiz.objects.all()

class Query(ObjectType):
    course = graphene.Field(CourseType, id=graphene.Int())
    courses = graphene.List(CourseType)
    me = graphene.Field(UserType)
    users = graphene.List(UserType)
    usert = graphene.Field(UsetType, id=graphene.Int())
    userts = graphene.List(UsetType)
    clas = graphene.Field(ClassType, id=graphene.Int())
    classes = graphene.List(ClassType)
    teach = graphene.Field(TeachesType, id=graphene.Int())
    teaches = graphene.List(TeachesType)
    belong = graphene.Field(BelongsType, id=graphene.Int())
    belongs = graphene.List(BelongsType)
    answer = graphene.Field(AnswerType, id=graphene.Int())
    answers = graphene.List(AnswerType)
    option = graphene.Field(OptionsType, id=graphene.Int())
    options = graphene.List(OptionsType)
    take = graphene.Field(TakesType, id=graphene.Int())
    takes = graphene.List(TakesType)
    make = graphene.Field(MakesType, id=graphene.Int())
    makes = graphene.List(MakesType)
    questions = graphene.List(QuestionType)
    notifications = graphene.List(NotificationType)

    def resolve_me(self, info):
        user = info.context.user
        if user.is_anonymous:
            raise Exception('Not logged in!')
        return user

class QuizInput(graphene.InputObjectType):
    quiz_name = graphene.String()
    access_code = graphene.String()
    start_time = graphene.DateTime()
    end_time = graphene.DateTime()
    publish_time = graphene.DateTime()
    duration = graphene.Int()
    times_can_take = graphene.Int()
    linear=graphene.Boolean()
    shuffle=graphene.Boolean()
    course=graphene.ID()
    marks=graphene.Int()

class QuizUInput(graphene.InputObjectType):
    quiz_name = graphene.String()
    access_code = graphene.String()
    start_time = graphene.DateTime()
    end_time = graphene.DateTime()
    publish_time = graphene.DateTime()
    duration = graphene.Int()
    times_can_take = graphene.Int()
    linear=graphene.Boolean()
    shuffle=graphene.Boolean()
    course=graphene.String()
    marks=graphene.Int()

class CreatetempQuiz(graphene.Mutation):
    class Arguments:
        quiz_name = graphene.String(required=True)
        access_code = graphene.String(required=True)

    ok = graphene.Boolean()
    Quiz = graphene.Field(QuizType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, quiz_name=None, access_code = None):
        ok = True
        quiz_instance = Quiz(quiz_name=quiz_name,access_code=access_code)
        quiz_instance.save()
        return CreatetempQuiz(ok=ok, Quiz=quiz_instance)

class CreateQuiz(graphene.Mutation):
    class Arguments:
        input = QuizInput(required=True)

    ok = graphene.Boolean()
    quiz = graphene.Field(QuizType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = True
        quiz_instance = Quiz(quiz_name=input.quiz_name,access_code=input.access_code,start_time=input.start_time,end_time=input.end_time,publish_time=input.publish_time,duration=input.duration,times_can_take=input.times_can_take,linear=input.linear,shuffle=input.shuffle,course=Course.objects.get(pk=input.course),marks=input.marks)
        quiz_instance.save()
        return CreateQuiz(ok=ok, quiz=quiz_instance)

class UpdateQuiz(graphene.Mutation):
    class Arguments:
        input = QuizUInput(required=True)

    ok = graphene.Boolean()
    quiz = graphene.Field(QuizType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = False
        quiz_instance =  Quiz.objects.filter(quiz_name=input.quiz_name,access_code=input.access_code)
        if quiz_instance:
            ok = True
            quiz_instance.update(start_time=input.start_time,end_time=input.end_time,publish_time=input.publish_time,duration=input.duration,times_can_take=input.times_can_take,linear=input.linear,shuffle=input.shuffle,course=Course.objects.get(course_id=input.course),marks=input.marks)
            quiz_instance=quiz_instance[0]
            quiz_instance.save()
            return UpdateQuiz(ok=ok, quiz=quiz_instance)
        return UpdateQuiz(ok=ok, quiz=None)


class CheckEmail(graphene.Mutation):
    class Arguments:
        username = graphene.String(required=True)

    ok = graphene.Boolean()
    accessCode=graphene.String()
    @staticmethod
    def mutate(root, info, username=None):
        ok = False
        try:
            user = User.objects.get(username=username)
        except:
            raise TypeError("Enter valid Credentials")
        if user and user.email is not None and user.email != "":
            ok = True
            code = ''.join(secrets.choice(string.ascii_uppercase +string.ascii_lowercase + string.digits) for i in range(8))
            send_mail(
    		'Quizter',
    		'''Hi '''+str(user.username)+''',\n   You have recently requested for a password change for your account. The following code is the unique security code and please enter it when asked for.\n\n   Security Code:\t'''+code+'''\n\n   We hope this leads to succesful recovery of your account.\nRegards,\nQuizter Team.''',
    		'quizterTeam@gmail.com',
    		[user.email],
    		fail_silently=False,
			)
            return CheckEmail(ok=ok,accessCode=code)
        return CheckEmail(ok=ok,accessCode=None)

class FailedLogin(graphene.Mutation):
    class Arguments:
        username = graphene.String(required=True)

    ok = graphene.Boolean()
    accessCode=graphene.String()
    @staticmethod
    def mutate(root, info, username=None):
        ok = False
        try:
            user = User.objects.get(username=username)
        except:
            raise TypeError("Enter valid Credentials")
        if user and user.email is not None and user.email != "":
            ok = True
            code = ''.join(secrets.choice(string.ascii_uppercase +string.ascii_lowercase + string.digits) for i in range(8))
            send_mail(
    		'Quizter',
    		'''Hi '''+str(user.username)+''',\n   Your account has been inappropriately being used. \n We suggest you to change your password.\n\n   We hope this leads to succesful recovery of your account.\nRegards,\nQuizter Team.''',
    		'quizterTeam@gmail.com',
    		[user.email],
    		fail_silently=False,
			)
            return CheckEmail(ok=ok,accessCode=code)
        return CheckEmail(ok=ok,accessCode=None)

class ChangePassword(graphene.Mutation):
    class Arguments:
        username = graphene.String(required=True)
        password = graphene.String(required=True)

    ok = graphene.Boolean()
    @staticmethod
    def mutate(root, info, username=None,password=None):
        ok = False
        try:
            user = User.objects.get(username=username)
        except:
            raise TypeError("Enter valid Credentials")
        if user:
            ok = True
            user.set_password(password)
            user.save()
            return ChangePassword(ok=ok)
        return ChangePassword(ok=ok)

class DeleteQuiz(graphene.Mutation):
    class Arguments:
        quiz_name = graphene.String(required=True)
        access_code = graphene.String(required=True)

    ok = graphene.Boolean()
    Quiz = graphene.Field(QuizType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, quiz_name=None, access_code = None):
        ok = False
        quiz_instance = Quiz.objects.filter(quiz_name=quiz_name,access_code=access_code)
        if quiz_instance:
            ok = True
            quiz_instance.delete()
            return DeleteQuiz(ok=ok, Quiz=quiz_instance)
        return DeleteOptions(ok=ok, Quiz=None)

class MakesInput(graphene.InputObjectType):
    quiz = graphene.ID()
    user = graphene.ID()

class CreateMakes(graphene.Mutation):
    class Arguments:
        input = MakesInput(required=True)

    ok = graphene.Boolean()
    makes = graphene.Field(MakesType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = True
        makes_instance = Makes(quiz=Quiz.objects.get(pk=input.quiz),user=UserT.objects.get(pk=input.user))
        makes_instance.save()
        return CreateMakes(ok=ok, makes=makes_instance)

class DeleteMakes(graphene.Mutation):
    class Arguments:
        input = MakesInput(required=True)

    ok = graphene.Boolean()
    makes = graphene.Field(MakesType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = False
        makes_instance = Makes.objects.filter(quiz=Quiz.objects.get(pk=input.quiz),user=UserT.objects.get(pk=input.user))
        if makes_instance:
            ok = True
            makes_instance.delete()
            return DeleteMakes(ok=ok, makes=makes_instance)
        return DeleteMakes(ok=ok, makes=None)

class TakesInput(graphene.InputObjectType):
    quiz = graphene.ID()
    user = graphene.ID()
    start_time= graphene.DateTime()
    times_taken = graphene.Int()
    submission= graphene.String()
    nemail= graphene.Boolean()

class CreateTakes(graphene.Mutation):
    class Arguments:
        input = TakesInput(required=True)

    ok = graphene.Boolean()
    takes = graphene.Field(TakesType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = True
        takes_instance = Takes(quiz=Quiz.objects.get(pk=input.quiz),user=UserT.objects.get(pk=input.user),start_time=input.start_time,times_taken=input.times_taken,submission=input.submission,nemail=input.nemail)
        takes_instance.save()
        return CreateTakes(ok=ok, takes=takes_instance)

class DeleteTakes(graphene.Mutation):
    class Arguments:
        input = TakesInput(required=True)

    ok = graphene.Boolean()
    takes = graphene.Field(TakesType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = False
        takes_instance = Takes.objects.filter(quiz=Quiz.objects.get(pk=input.quiz),user=UserT.objects.get(pk=input.user),start_time=input.start_time,times_taken=input.times_taken,submission=input.submission,nemail=input.nemail)
        if takes_instance:
            ok = True
            takes_instance.delete()
            return DeleteTakes(ok=ok, takes=takes_instance)
        return DeleteTakes(ok=ok, takes=None)

class UpdateSTakes(graphene.Mutation):
    class Arguments:
        input = TakesInput(required=True)

    ok = graphene.Boolean()
    takes = graphene.Field(TakesType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = False
        takes_instance =  Takes.objects.filter(quiz=Quiz.objects.get(pk=input.quiz),user=UserT.objects.get(pk=input.user))
        if takes_instance:
            ok = True
            if(not input.start_time):
                takes_instance.update(times_taken=takes_instance[0].times_taken+1)
            if(input.start_time):
                takes_instance.update(start_time=input.start_time)
            takes_instance=takes_instance[0]
            takes_instance.save()
            return UpdateSTakes(ok=ok, takes=takes_instance)
        return UpdateSTakes(ok=ok, takes=None)


class DeleteTTakes(graphene.Mutation):
    class Arguments:
        input = TakesInput(required=True)

    ok = graphene.Boolean()
    takes = graphene.Field(TakesType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = False
        takes_instance = Takes.objects.filter(quiz=Quiz.objects.get(pk=input.quiz),user=UserT.objects.get(pk=input.user))
        if takes_instance:
            ok = True
            takes_instance.delete()
            return DeleteTTakes(ok=ok, takes=takes_instance)
        return DeleteTTakes(ok=ok, takes=None)

class CreateTTakes(graphene.Mutation):
    class Arguments:
        input = TakesInput(required=True)
    ok = graphene.Boolean()
    takes = graphene.Field(TakesType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = True
        takes_instance = Takes(quiz=Quiz.objects.get(pk=input.quiz),user=UserT.objects.get(pk=input.user),nemail=input.nemail)
        takes_instance.save()
        return CreateTakes(ok=ok, takes=takes_instance)

class OptionsInput(graphene.InputObjectType):
    userId = graphene.ID()
    quesId = graphene.ID()
    answerId = graphene.ID()

class CreateOptions(graphene.Mutation):
    class Arguments:
        input = OptionsInput(required=True)

    ok = graphene.Boolean()
    options = graphene.Field(OptionsType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = True
        options_instance = Options(question=Question.objects.get(pk=input.quesId),answer=Answer.objects.get(pk=input.answerId),user=UserT.objects.get(pk=input.userId))
        options_instance.save()
        return CreateOptions(ok=ok, options=options_instance)

class DeleteOptions(graphene.Mutation):
    class Arguments:
        input = OptionsInput(required=True)

    ok = graphene.Boolean()
    options = graphene.Field(OptionsType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = False
        options_instance = Options.objects.filter(question=Question.objects.get(pk=input.quesId),answer=Answer.objects.get(pk=input.answerId),user=UserT.objects.get(pk=input.userId))
        if options_instance:
            ok = True
            options_instance.delete()
            return DeleteOptions(ok=ok, options=options_instance)
        return DeleteOptions(ok=ok, options=None)

class AnswerInput(graphene.InputObjectType):
    quesId = graphene.ID()
    answer_text = graphene.String()

class CreateAnswer(graphene.Mutation):
    class Arguments:
        input = AnswerInput(required=True)

    ok = graphene.Boolean()
    answer = graphene.Field(AnswerType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = True
        answer_instance =   Answer(question=Question.objects.get(pk=input.quesId),answer_text=input.answer_text)
        answer_instance.save()
        return CreateAnswer(ok=ok, answer=answer_instance)

class DeleteAnswer(graphene.Mutation):
    class Arguments:
        input = AnswerInput(required=True)

    ok = graphene.Boolean()
    answer = graphene.Field(AnswerType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = False
        answer_instance =  Answer.objects.get(pk=input.quesId)
        if answer_instance:
            ok = True
            answer_instance.answer_text = input.answer_text
            answer_instance.save()
            return DeleteAnswer(ok=ok, answer=answer_instance)
        return DeleteAnswer(ok=ok, answer=None)

class QuestionInput(graphene.InputObjectType):
    quiz = graphene.ID()
    question_text = graphene.String()
    question_type = graphene.String()
    question_mark = graphene.Int()
    question_n_mark = graphene.Int()

class CreateQuestion(graphene.Mutation):
    class Arguments:
        input = QuestionInput(required=True)

    ok = graphene.Boolean()
    question = graphene.Field(QuestionType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = True
        question_instance =  Question(quiz=Quiz.objects.get(pk=input.quiz),question_text=input.question_text,question_type=input.question_type,question_mark=input.question_mark,question_n_mark=input.question_n_mark)
        question_instance.save()
        return CreateQuestion(ok=ok, question=question_instance)

class UpdateQuestion(graphene.Mutation):
    class Arguments:
        id = graphene.ID(required=True)
        input = QuestionInput(required=True)

    ok = graphene.Boolean()
    question = graphene.Field(QuestionType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None,id=None):
        ok = False
        question_instance =  Question.objects.filter(pk=id)
        if question_instance:
            ok = True
            question_instance.update(quiz=Quiz.objects.get(pk=input.quiz),question_text=input.question_text,question_type=input.question_type,question_mark=input.question_mark,question_n_mark=input.question_n_mark)
            question_instance=question_instance[0]
            question_instance.save()
            return UpdateQuestion(ok=ok, question=question_instance)
        return UpdateQuestion(ok=ok, question=None)

class DeleteQuestion(graphene.Mutation):
    class Arguments:
        id = graphene.ID(required=True)

    ok = graphene.Boolean()
    question = graphene.Field(QuestionType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, id=None):
        ok = False
        question_instance =  Question.objects.get(pk=id)
        if question_instance:
            ok = True
            question_instance.delete()
            return DeleteQuestion(ok=ok, question=question_instance)
        return DeleteQuestion(ok=ok, question=None)

class AnswerFInput(graphene.InputObjectType):
    quesId = graphene.ID()
    answer_text = graphene.String()
    correct = graphene.Boolean()
    feedback= graphene.String()

class CreateFAnswer(graphene.Mutation):
    class Arguments:
        input = AnswerFInput(required=True)

    ok = graphene.Boolean()
    answer = graphene.Field(AnswerType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = True
        answer_instance =   Answer(question=Question.objects.get(pk=input.quesId),answer_text=input.answer_text,correct = input.correct,feedback=input.feedback)
        answer_instance.save()
        return CreateFAnswer(ok=ok, answer=answer_instance)


class DeleteFAnswer(graphene.Mutation):
    class Arguments:
        id=graphene.ID(required=True)
        answer=graphene.String(required=True)

    ok = graphene.Boolean()
    answer = graphene.Field(AnswerType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, id=None,answer=None):
        ok = False
        answer_instance =  Answer.objects.get(question=Question.objects.get(pk=id),answer_text=answer)
        if answer_instance:
            ok = True
            answer_instance.delete()
            return DeleteFAnswer(ok=ok, answer=answer_instance)
        return DeleteFAnswer(ok=ok, answer=None)

class NotificationInput(graphene.InputObjectType):
    user = graphene.String()
    notifi=graphene.String()

class DeleteNotification(graphene.Mutation):
    class Arguments:
        input = NotificationInput(required=True)

    ok = graphene.Boolean()
    Notification = graphene.Field(NotificationType)

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info, input=None):
        ok = False
        notification_instance = Notification.objects.filter(user=UserT.objects.get(user=User.objects.get(username=input.user)),Notification=input.notifi)
        if notification_instance:
            ok = True
            notification_instance.delete()
            return DeleteNotification(ok=ok, Notification=notification_instance)
        return DeleteNotification(ok=ok, Notification=None)

class Calculate(graphene.Mutation):
    class Arguments:
        uid = graphene.ID(required=True)
        qid = graphene.ID(required=True)

    ok = graphene.Boolean()

    @staticmethod
    @permissions_checker([IsAuthenticated])
    def mutate(root, info,uid =None,qid =None ):
        ok = True
        marks=0
        Question_list= Question.objects.filter(quiz=Quiz.objects.get(pk=qid))
        try:
            for i in Question_list:
                if i.question_type == "sca" or i.question_type == "mca":
                    answers=Answer.objects.filter(question=i,correct=True)
                    options= Options.objects.filter(question=i,user=UserT.objects.get(pk=uid))
                    for j in options:
                        if j.answer in answers:
                            marks+=i.question_mark/len(answers)
                        else:
                            marks-=i.question_n_mark/len(answers)
                elif i.question_type == "fitb" or i.question_type == "num":
                    answers=Answer.objects.filter(question=i,correct=True)
                    options= Options.objects.filter(question=i,user=UserT.objects.get(pk=uid))
                    for j in options:
                        f=0
                        for k in answers:
                            if str(j.answer) == str(k):
                                marks+=i.question_mark
                                f+=1
                                break
                            print(k.user)
                        if f==0:
                            marks-=i.question_n_mark

            takes=Takes.objects.filter(quiz=Quiz.objects.get(pk=qid),user=UserT.objects.get(pk=uid))
            takes.update(marks=marks)
        except:
            ok=False
        return Calculate(ok=ok)

class Mutation(graphene.ObjectType):
    create_options = CreateOptions.Field()
    delete_options = DeleteOptions.Field()
    create_answer = CreateAnswer.Field()
    delete_answer = DeleteAnswer.Field()
    create_quiz = CreateQuiz.Field()
    update_quiz = UpdateQuiz.Field()
    delete_quiz = DeleteQuiz.Field()
    create_fanswer = CreateFAnswer.Field()
    delete_fanswer = DeleteFAnswer.Field()
    create_question = CreateQuestion.Field()
    update_question = UpdateQuestion.Field()
    delete_question = DeleteQuestion.Field()
    create_tquiz = CreatetempQuiz.Field()
    create_makes = CreateMakes.Field()
    delete_makes = DeleteMakes.Field()
    create_t_takes = CreateTTakes.Field()
    delete_t_takes=DeleteTTakes.Field()
    create_takes = CreateTakes.Field()
    update_s_takes=UpdateSTakes.Field()
    delete_takes = DeleteTakes.Field()
    delete_notification=DeleteNotification.Field()
    check_email=CheckEmail.Field()
    failedlogin=FailedLogin.Field()
    calculate=Calculate.Field()
    change_password=ChangePassword.Field()
    token_auth = graphql_jwt.ObtainJSONWebToken.Field()
    verify_token = graphql_jwt.Verify.Field()
    refresh_token = graphql_jwt.Refresh.Field()

schema = graphene.Schema(query=Query, mutation=Mutation)

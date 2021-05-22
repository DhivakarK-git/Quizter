from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator
from django.core.exceptions import ValidationError
from django.core.mail import send_mail

QTYPE=[('sca','Single Correct Answer'),('mca','Multiple Correct Answer'),('fitb','Fill In The Blanks'),('short','Short Answer'),('num','Numerical')]
TYPE=[('student','Student'),('faculty','Faculty'),('admin','Admin')]

class UserT(models.Model):
	user = models.OneToOneField(User, on_delete=models.CASCADE)
	type = models.CharField(max_length=10,choices=TYPE,default=None,blank=False)
	def __str__(self):
		return self.user.username
	class Meta:
		verbose_name = "User Type"
		verbose_name_plural = "User Type"

	def save(self,*args, **kwargs):
		super().save(*args,**kwargs)
		Notification(user=self,Notification ="You have been added as a "+str(self.type)+".").save()

class Course(models.Model):
	course_id=models.CharField(max_length=255, default='')
	course_name = models.CharField(max_length=255, default='')

	def __str__(self):
		return self.course_id
	class Meta:
		verbose_name = "Course"
		verbose_name_plural = "Courses"
		unique_together = ('course_id',)

class Clas(models.Model):
	class_name = models.CharField(max_length=255, default='',unique=True)
	def __str__(self):
		return self.class_name
	class Meta:
		verbose_name = "Class"
		verbose_name_plural = "Classes"

class Teaches(models.Model):
	user = models.ForeignKey(UserT, on_delete=models.CASCADE, default=None)
	clas = models.ForeignKey(Clas, on_delete=models.CASCADE, default=None)
	course = models.ForeignKey(Course, on_delete=models.CASCADE, default=None)
	def __str__(self):
		return ""
	def clean(self):
		if(str(self.user.type) == 'faculty'):
			pass
		else:
			raise ValidationError("Not a Faculty")

	def save(self,*args, **kwargs):
		super().save(*args,**kwargs)
		Notification(user=self.user,Notification ="You have been assigned to teach "+str(self.course)+" to "+str(self.clas)).save()
	def delete(self,*args, **kwargs):
		super().delete(*args,**kwargs)
		Notification(user=self.user,Notification =str(self.course)+" to "+str(self.clas)+" is now not part of your Timetable").save()
	class Meta:
		verbose_name = "Assigned Faculty"
		verbose_name_plural = "Assigned Faculty"
		unique_together = ('user', 'clas','course')


class Belongs(models.Model):
	user = models.ForeignKey(UserT, on_delete=models.CASCADE, default=None)
	clas = models.ForeignKey(Clas, on_delete=models.CASCADE, default=None)
	class Meta:
		verbose_name = "Student"
		verbose_name_plural = "Students"
		unique_together = ('user', 'clas',)
	def clean(self):
		if(str(self.user.type) == 'student'):
			pass
		else:
			raise ValidationError("Not a student")

	def save(self,*args, **kwargs):
		super().save(*args,**kwargs)
		Notification(user=self.user,Notification ="You have been added to "+str(self.clas)).save()
		teachers=Teaches.objects.filter(clas=self.clas)
		for i in teachers:
			Notification(user=i.user,Notification =str(self.user)+" of class "+str(self.clas)+" has been added to your course "+str(i.course)).save()
	def delete(self,*args, **kwargs):
		super().delete(*args,**kwargs)
		Notification(user=self.user,Notification ="You have been removed from "+str(self.clas)).save()
		teachers=Teaches.objects.filter(clas=self.clas)
		for i in teachers:
			Notification(user=i.user,Notification =str(self.user)+" of class "+str(self.clas)+" has been removed from your course "+str(i.course)).save()

	def __str__(self):
		return "Student"

class Quiz(models.Model):
	quiz_name = models.CharField(max_length=255, default='')
	access_code = models.CharField(max_length=50, default='quizter')
	start_time = models.DateTimeField(null=True)
	end_time = models.DateTimeField(null=True)
	publish_time = models.DateTimeField(null=True)
	duration = models.IntegerField(validators=[MinValueValidator(1),MaxValueValidator(240)],null=True)
	times_can_take = models.IntegerField(default=1,null=True)
	linear=models.BooleanField(default=True)
	shuffle=models.BooleanField(default=True)
	course=models.ForeignKey(Course, on_delete=models.CASCADE, default=None,null=True)
	marks=models.IntegerField(default=1,validators=[MinValueValidator(1),
                                       MaxValueValidator(500)],null=True)

	class Meta:
		verbose_name = "Quiz"
		verbose_name_plural = "Quizzes"
		ordering = ['id']

	def __str__(self):
		return self.quiz_name

class Question(models.Model):
	quiz = models.ForeignKey(
		Quiz,
		related_name='questions', # need related name for hyper link related field to work ?!?
		on_delete=models.CASCADE
	)
	question_text = models.CharField(max_length=255, default='')
	question_type = models.CharField(max_length=24,choices=QTYPE,default=None,blank=False)
	question_mark = models.IntegerField(default=1,validators=[MinValueValidator(0),
                                       MaxValueValidator(500)])
	question_n_mark = models.IntegerField(default=0,validators=[MinValueValidator(-250),
                                       MaxValueValidator(0)])
	q_image=models.ImageField(upload_to='question',default=None, blank=True, null=True)
	class Meta:
		unique_together = ('quiz', 'question_text',)
		ordering = ['id']

	def __str__(self):
		return self.question_text

class Answer(models.Model):
	question = models.ForeignKey(
		Question,
		related_name='answers',
		on_delete=models.CASCADE
	)
	answer_text = models.CharField(max_length=255)
	correct = models.BooleanField(default=False)
	feedback=models.CharField(max_length=255,default=None, blank=True, null=True)
	a_image=models.ImageField(upload_to='answer',default=None, blank=True, null=True)

	class Meta:
		verbose_name = "Option"
		verbose_name_plural = "Options"
		unique_together = ('question', 'answer_text','correct')

	def __str__(self):
		return self.answer_text

class Options(models.Model):
	question = models.ForeignKey(
		Question,
		related_name='options',
		on_delete=models.CASCADE
	)
	user = models.ForeignKey(UserT, on_delete=models.DO_NOTHING, default=None)
	answer = models.ForeignKey(Answer, on_delete=models.DO_NOTHING, default=None)
	class Meta:
		verbose_name = "Selected Option"
		verbose_name_plural = "Selected Options"
		unique_together = ('question', 'user','answer')

class Takes(models.Model):
	quiz = models.ForeignKey(
		Quiz,
		related_name='takers', # need related name for hyper link related field to work ?!?
		on_delete=models.DO_NOTHING
	)
	user = models.ForeignKey(UserT, on_delete=models.DO_NOTHING, default=None)
	start_time= models.DateTimeField(blank=True,null=True)
	times_taken = models.IntegerField(default=0,blank=True,null=True)
	submission=models.CharField(max_length=30,blank=True,null=True)
	nemail=models.BooleanField(default=False,blank=True,null=True)
	marks=models.FloatField(default=0,validators=[MinValueValidator(0),
                                       MaxValueValidator(500)])
	def clean(self):
		if(str(self.user.type) == 'student'):
			pass
		else:
			raise ValidationError("Not a student")
	class Meta:
		verbose_name = "Take"
		verbose_name_plural = "Takes"
		unique_together = ('user','quiz')

	def save(self,*args, **kwargs):
		super().save(*args,**kwargs)
		if(self.nemail== True):
			Notification(user=self.user,Notification ="A quiz Named: "+str(self.quiz.quiz_name)+" has been assigned to you.\n Start Time: "+str(self.quiz.start_time)+"\n End Time: "+str(self.quiz.end_time)+"\n ALL THE BEST").save()
			send_mail(
    		'Quizter',
    		'''Hi '''+str(self.user.user.username)+''',\n   A quiz Named : '''+str(self.quiz.quiz_name)+''' has been assigned to you.\n   Start Time: '''+str(self.quiz.start_time)+'''\n   End Time: '''+str(self.quiz.end_time)+'''\n\tALL THE BEST.\nRegards,\nQuizter Team.''',
    		'quizterTeam@gmail.com',
    		[self.user.user.email],
    		fail_silently=False,
			)

class Makes(models.Model):
	quiz = models.ForeignKey(
		Quiz,
		related_name='makers', # need related name for hyper link related field to work ?!?
		on_delete=models.CASCADE
	)
	user = models.ForeignKey(UserT, on_delete=models.DO_NOTHING, default=None)
	def clean(self):
		if(str(self.user.type) == 'faculty'):
			pass
		else:
			raise ValidationError("Not a faculty")
	class Meta:
		verbose_name = "Make"
		verbose_name_plural = "Makes"

class Notification(models.Model):
	user = models.ForeignKey(UserT, on_delete=models.CASCADE, default=None)
	Notification=models.CharField(max_length=255)

	def __str__(self):
		return str(self.user)+" - Notification: "+self.Notification

	class Meta:
		verbose_name = "Notification"
		verbose_name_plural = "Notifications"

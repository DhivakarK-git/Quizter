from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin,AdminPasswordChangeForm
from .models import UserT,Course,Clas,Teaches,Belongs,Quiz,Question,Answer,Options,Takes,Makes,Notification
from django.contrib.auth.models import User,Group
from django.contrib import admin
from django.contrib.admin import AdminSite
from django.core.mail import send_mail

admin.site.site_header = 'Quizter'
admin.site.site_title = 'Quizter'
admin.site.index_title = "ADMIN ACCOUNT"


class UserInline(admin.StackedInline):
    model = UserT
    extra = 1

class UserAdmin(DjangoUserAdmin):
    list_display = ('username','email', 'first_name', 'last_name','is_superuser')
    inlines = (UserInline, )
    def save_model(self, request, obj, form, change):
        obj.user = request.user
        super().save_model(request, obj, form, change)
        try:
            a=UserT.objects.filter(user=obj)
            send_mail(
    		'Quizter',
    		'''Hi \n Your details have been updated. \n your new details are:\n username: '''+str(a[0].user.username)+'''\n First Name: '''+str(a[0].user.first_name)+'''\n Last Name: '''+str(a[0].user.last_name)+'''\n email: '''+str(a[0].user.email)+'''\n Type: '''+str(a[0].type)+'''\n\n   We hope this leads to succesful recovery of your account.\nRegards,\nQuizter Team.''',
    		'quizterTeam@gmail.com',
    		[a[0].user.email],
    		fail_silently=False,
			)
            print(a[0].user.email)
            Notification(user=a[0],Notification ="Your details have been updated.").save()

        except:
            pass

class AnswerInline(admin.TabularInline):
    model = Answer
    extra = 0

class QuestionInline(admin.StackedInline):
    model = Question
    extra = 0

class BelongsInline(admin.TabularInline):
    model = Belongs
    extra = 0

class TeachesInline(admin.TabularInline):
    model = Teaches
    extra = 0


class ClassAdmin(admin.ModelAdmin):
    inlines=(BelongsInline,)

class QuesAdmin(admin.ModelAdmin):
    inlines=(AnswerInline,)

class QuizAdmin(admin.ModelAdmin):
    inlines=(QuestionInline,)

class CourseAdmin(admin.ModelAdmin):
    inlines=(TeachesInline,)


admin.site.unregister(User)
admin.site.register(User,UserAdmin)
admin.site.unregister(Group)
admin.site.register(Course,CourseAdmin)
admin.site.register(Answer)
admin.site.register(Clas,ClassAdmin)
admin.site.register(Quiz,QuizAdmin)
admin.site.register(Question,QuesAdmin)
admin.site.register(Takes)
admin.site.register(Makes)

#to be removed
admin.site.register(Options)
admin.site.register(Notification)

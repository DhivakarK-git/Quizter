from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin,AdminPasswordChangeForm
from .models import UserT,Course,Clas,Teaches,Belongs,Quiz,Question,Answer,Options,Takes,Makes,Notification
from django.contrib.auth.models import User,Group
from django.contrib import admin

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
admin.site.register(Options)
admin.site.register(Takes)
admin.site.register(Makes)
admin.site.register(Notification)

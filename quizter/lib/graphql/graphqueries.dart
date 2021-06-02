class GraphQueries {
  String validateUser({String username, String password}) {
    return '''
mutation {
  tokenAuth(username: "$username", password: "$password") {
    token
  }
}
''';
  }

  String checkEmail({String username}) {
    return '''
  mutation{
  checkEmail(username: "$username") {
    ok
    accessCode
  }
}

''';
  }

  String changePassword({String username, String password}) {
    return '''
  mutation{
  changePassword(username: "$username",password:"$password") {
    ok
  }
}
''';
  }

  String createAnswer({int quesId, String answerText}) {
    return '''
mutation{
  createAnswer(input:{quesId:$quesId,answerText:"$answerText"}){
    ok
    answer{
      id
      answerText
    }
  }
}
''';
  }

  String updateAnswer({int answerId, String answerText}) {
    return '''
mutation {
  deleteAnswer(input: {quesId:$answerId, answerText: "$answerText"}) {
    ok
  }
}
''';
  }

  String deleteQuestion({int id}) {
    return '''
mutation{
  deleteQuestion(id:$id){
    ok
  }
}
''';
  }

  String createOption({int userId, int quesId, int answerId}) {
    return '''
mutation {
  createOptions(input: {userId: $userId, quesId: $quesId, answerId: $answerId}) {
    ok
  }
}
''';
  }

  String deleteOption({int userId, int quesId, int answerId}) {
    return '''
mutation {
  deleteOptions(input: {userId: $userId, quesId: $quesId, answerId: $answerId}) {
    ok
  }
}
''';
  }

  String getUser() {
    return '''
{
  me{
    username
    firstName
    lastName
    usert{
      id
      type
    }
  }
}
''';
  }

  String getNotification() {
    return '''
    {
me{
  usert{
    notificationSet{
      Notification
    }
  }
}
}
''';
  }

  String deleteNotification(String user, String notification) {
    return '''
mutation {
  deleteNotification(input: {user: "$user",notifi:"$notification"}) {
    ok
  }
}
  ''';
  }

  String updateTQuiz(
      {String quizname,
      String accesscode,
      String start,
      String end,
      String publish,
      int duration,
      int times,
      bool linear,
      bool shuffle,
      int marks,
      String course}) {
    return '''
mutation {
  updateQuiz(input: {quizName: "$quizname", accessCode: "$accesscode", startTime: "$start", endTime: "$end", publishTime: "$publish", duration: $duration, timesCanTake: $times, linear: $linear, shuffle: $shuffle, course: "$course", marks: $marks}) {
    ok
  }
}
''';
  }

  String getteaches() {
    return '''
{
me{
  usert{
    teachesSet{
      course{
        courseId
      }
      clas{
      className
      }
    }
  }
}
}
''';
  }

  String getOptions({int quizId, int quesId}) {
    return '''
{
  me{
    usert{
      takesSet{
        quiz(id:$quizId){
          question(id:$quesId){
            id
            options{
              id
              answer{
              id
              answerText
            }
              question {
                id
              }
              user {
                id
              }
            }
          }
        }
      }
    }
  }
}
''';
  }

  String getQuiz(int quizid) {
    return '''
{
  me {
    usert {
    id
      takesSet {
        quiz(id: $quizid) {
          quizName
          accessCode
          questions {
            id
            questionText
            questionType
            questionMark
            answers {
              id
              answerText
              correct
            }
          }
        }
      }
    }
  }
}
''';
  }

  String getFQuiz(int quizid) {
    return '''
{
  me {
    usert {
    id
      makesSet {
        quiz(id: $quizid) {
          quizName
          accessCode
          duration
          endTime
          questions {
            id
            questionText
            questionType
            questionMark
            questionNMark
            answers {
              id
              answerText
              correct
              feedback
            }
          }
        }
      }
    }
  }
}
''';
  }

  String listQuestions() {
    return '''
{
  me {
    usert {
      makesSet {
        quizzes {
          questions {
            id
            questionText
            questionType
            questionMark
            questionNMark
            answers {
              id
              answerText
              correct
              feedback
            }
          }
        }
      }
    }
  }
}
    ''';
  }

  String courselist() {
    return '''
 {
  me {
    usert {
      belongsSet {
        clas {
          className
          teachesSet {
            course {
              courseId
              courseName
            }
          }
        }
        user {
          id
          takesSet {
            quizzes {
              id
              quizName
              startTime
              endTime
              course {
                courseId
              }
              marks
              timesCanTake
              takers {
                user {
                  id
                }
                marks
                timesTaken
              }
            }
          }
          user {
            username
            firstName
            lastName
            email
          }
        }
      }
    }
  }
}
''';
  }

  String resultlist() {
    return '''
 {
  me {
    usert {
      belongsSet {
        clas {
          className
          teachesSet {
            course {
              courseId
              courseName
            }
          }
        }
        user {
          id
          takesSet {
            quizzes {
              id
              quizName
              startTime
              endTime
              publishTime
              course {
                courseId
              }
              marks
              timesCanTake
              takers {
                user {
                  id
                }
                marks
                timesTaken
              }
            }
          }
          user {
            username
            firstName
            lastName
            email
          }
        }
      }
    }
  }
}
''';
  }

  String getEQuiz(int quizid) {
    return '''
{
  me {
    usert {
    id
      makesSet {
        quiz(id: $quizid) {
          quizName
          accessCode
          duration
          startTime
          endTime
          publishTime
          linear
          shuffle
          timesCanTake
          questions {
            id
            questionText
            questionType
            questionMark
            questionNMark
            answers {
              id
              answerText
              correct
              feedback
            }
          }
        }
      }
    }
  }
}
''';
  }

  String calculate(int userId, int quizId) {
    return '''
mutation {
  calculate(uid: $userId,qid:$quizId) {
    ok
  }
}
  ''';
  }

  String getMeQuiz() {
    return '''
{
  me {
    usert {
      id
      takesSet {
        quizzes {
          id
          quizName
          course {
            courseId
          }
          startTime
          endTime
          linear
          duration
          marks
          timesCanTake
          takers {
            user {
              id
            }
            timesTaken
            startTime
          }
        }
      }
    }
  }
}
''';
  }

  String getTQuiz() {
    return '''
{
  me {
    usert {
      id
      makesSet {
        quizzes {
          id
          quizName
          accessCode
          course {
            courseId
          }
          startTime
          endTime
          duration
          linear
          marks
          makers {
            user {
              id
            }
          }
        }
      }
    }
  }
}
''';
  }

  String setMakes({int quizId, int userId}) {
    return '''
mutation {
  createMakes(input: {quiz: $quizId, user: $userId}) {
    ok
  }
}
''';
  }

  String setTakes({int quizId, int userId, bool nemail}) {
    return '''
mutation{
  createTTakes(input:{user:$userId,quiz:$quizId,nemail:$nemail}){
    ok
  }
}
''';
  }

  String removeTakes({int quizId, int userId}) {
    return '''
mutation{
  deleteTTakes(input:{user:$userId,quiz:$quizId}){
    ok
  }
}
''';
  }

  String classList() {
    return '''
{
  me {
    usert {
      teachesSet {
        course {
          courseId
          courseName
        }
        clas {
          className
          belongsSet {
            user {
              id
              takesSet {
                quizzes {
                  id
                  quizName
                  course{
                    courseId
                  }
                  marks
                  timesCanTake
                  takers {
                    user {
                      id
                    }
                    marks
                    timesTaken
                  }
                }
              }
              user {
                username
                firstName
                lastName
                email
              }
            }
          }
        }
      }
    }
  }
}
''';
  }

  String takersList(quizID) {
    return '''
{
  me{
    usert{
      makesSet{
        quiz(id:$quizID){
          takers{
            user{
              id
            }
          }
        }
      }
    }
  }
}
''';
  }

  String saveTQuiz({String quizname, String accesscode}) {
    return '''
mutation{
  createTquiz(quizName:"$quizname",accessCode:"$accesscode"){
    ok
    Quiz{
      id
    }
  }
}
''';
  }

  String saveQuestion({
    int quizId,
    String question,
    String type,
    int pmark,
    int nmark,
  }) {
    return '''
mutation {
  createQuestion(input: {quiz: $quizId, questionText: "$question",questionType :"${type.toLowerCase()}" ,questionMark : $pmark,questionNMark:$nmark}) {
    ok
    question {
      id
    }
  }
}
''';
  }

  String updateQuestion({
    int quesId,
    int quizId,
    String question,
    String type,
    int pmark,
    int nmark,
  }) {
    return '''
mutation {
  updateQuestion(id:$quesId,input: {quiz: $quizId, questionText: "$question",questionType :"${type.toLowerCase()}" ,questionMark : $pmark,questionNMark:$nmark}) {
    ok
    question{
      id
      answers{
        answerText
      }
    }
  }
}
''';
  }

  String updateTimes({int userid, int quizid}) {
    return '''
mutation{
  updateSTakes(input:{user:$userid,quiz:$quizid}){
    ok
  }
}
''';
  }

  String updateStartTime({int userid, int quizid, String dt}) {
    return '''
mutation{
  updateSTakes(input:{user:$userid,quiz:$quizid,startTime:"$dt"}){
    ok
  }
}
''';
  }

  String saveFAnswer({
    int quesId,
    String answer,
    String feedback,
    bool correct,
  }) {
    return '''
  mutation {
  createFanswer(input: {quesId: $quesId, answerText: "$answer",correct:$correct ,feedback : "$feedback",}) {
    ok
  }
}
''';
  }

  String deleteFAnswer({
    int quesId,
    String answer,
  }) {
    return '''
mutation {
deleteFanswer(id:$quesId,answer:"$answer"){
  ok
}
}
''';
  }
}

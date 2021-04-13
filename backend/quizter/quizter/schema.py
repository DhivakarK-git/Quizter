import graphene
from graphql_auth.schema import UserQuery, MeQuery
from graphql_auth import mutations
import quizApp.schema

class Query(quizApp.schema.Query, graphene.ObjectType):
    # This class will inherit from multiple Queries
    # as we begin to add more apps to our project
    pass

class Mutation(quizApp.schema.Mutation, graphene.ObjectType):
    # This class will inherit from multiple Queries
    # as we begin to add more apps to our project
    pass
schema = graphene.Schema(query=Query, mutation=Mutation)

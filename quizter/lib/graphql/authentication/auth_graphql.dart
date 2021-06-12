import 'package:graphql/client.dart';

class AuthGraphQL {
  final baseURL = 'http://admin.quizter.codes/graphql/';
  static String _auth;

  void setAuth(String value) {
    _auth = value;
  }

  final _authLink = AuthLink(
    getToken: () async => 'JWT ' + _auth,
  );

  GraphQLClient getClient() => GraphQLClient(
        cache: GraphQLCache(),
        link: _authLink.concat(HttpLink(baseURL)),
      );
}

extension Graph on GraphQLClient {
  Future queryA(String query) {
    final String readCharacter = query;
    return this.query(QueryOptions(
      document: gql(readCharacter),
      fetchPolicy: FetchPolicy.noCache,
    ));
  }
}

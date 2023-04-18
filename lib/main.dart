import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MaterialApp(title: "GQL App", home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final HttpLink httpLink =
    HttpLink("https://countries.trevorblades.com/");
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(),
      ),
    );
    return GraphQLProvider(
      child: HomePage(),
      client: client,
    );
  }
}

class HomePage extends StatelessWidget {

  final String query = r"""
                    query GetContinent($code : ID!){
                      continent(code:$code){
                        name
                        countries{
                          name
                          emoji,
                          code
                        }
                      }
                    }
                  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GraphlQL Client"),
      ),
      body: Query(
        options: QueryOptions(
            document: gql(query),
            variables: const {"code": "AS"}),



        builder: (QueryResult result, { VoidCallback? refetch, FetchMore? fetchMore }) {
          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (result.data == null) {
            return Text("No Data Found !");
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Text(result.data?['continent']['countries'][index]['emoji']),
                        const SizedBox(width: 20.0,),
                        Text(result.data?['continent']['countries'][index]['name']),
                        const SizedBox(width: 10.0,),
                        Text("(${result.data?['continent']['countries'][index]['code']})"),
                      ],
                    ),
                  ),
                  Divider()
                ],
              );
              // return ListTile(
              //   title:
              //   Text(result.data?['continent']['countries'][index]['name']),
              // );
            },
            itemCount: result.data?['continent']['countries'].length,
          );
        },
      ),
    );
  }
}

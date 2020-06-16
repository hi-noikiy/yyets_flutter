import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/app/Stroage.dart';
import 'package:flutter_yyets/ui/pages/LoadingPageState.dart';
import 'package:flutter_yyets/ui/widgets/movie_tile.dart';

class SearchPageDelegate extends SearchDelegate<Map> {
  @override
  Widget buildSuggestions(BuildContext context) {
    return SuggestionPage(query, (q) {
      query = q;
      showResults(context);
    }, (q) {
      query = q;
    });
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = "";
              showSuggestions(context);
            }
          })
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () => close(context, null),
    );
  }

  //TODO fix 进入详情 返回会刷新
  @override
  Widget buildResults(BuildContext context) {
    var q = query;
    if (q.isEmpty) {
      query = "";
      return Container();
    } else {
      addQueryHistory(q);
      return ResultPage(q);
    }
  }
}

class SuggestionPage extends StatelessWidget {
  final String query;
  final Function onShowResult;
  final Function onQuery;

  SuggestionPage(this.query, this.onShowResult, this.onQuery);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: querySuggest(query),
      builder: (c, snap) {
        if (snap.connectionState == ConnectionState.done && !snap.hasError) {
          var suggestions = snap.data;
          return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (c, i) {
                return ListTile(
                  onTap: () {
                    onShowResult(suggestions[i]);
                  },
                  title: Text(suggestions[i]),
                  trailing: Container(
                    width: 20,
                    height: 20,
                    child: IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.all(0),
                      onPressed: () async {
                        await deleteQueryHistory(suggestions[i]);
                        onQuery(query);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ),
                );
              });
        } else {
          return Container();
        }
      },
    );
  }
}

class ResultPage extends StatefulWidget {
  final String query;

  ResultPage(this.query);

  @override
  State createState() => ResultPageState();
}

class ResultPageState extends LoadingPageState<ResultPage> {
  @override
  Future<List> fetchData(int page) => Api.search(widget.query, page);

  @override
  Widget buildItem(BuildContext context, int index, dynamic item) {
    item.putIfAbsent('id', () => item["itemid"]);
    item.remove('itemid');
    return MovieTile(item, item['title'], Container(), [
      item['area'],
      item['score'],
      item['play_status'],
      item['category'],
    ]);
  }

  Widget tagText(String s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
      child: Chip(
//      labelPadding: EdgeInsets.all(2),
//      padding: EdgeInsets.all(5),
        label: Text(s),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';

class PageViewerNavigationBar extends StatefulWidget {
  final Function nextHandler;
  final Function previousHandler;
  final PreloadPageController preloadPageController;
  final int totalPages;

  PageViewerNavigationBar(
      {@required this.nextHandler,
      @required this.previousHandler,
      @required this.preloadPageController,
      @required this.totalPages});

  @override
  State<StatefulWidget> createState() {
    return PageViewerNavigationBarState();
  }
}

class PageViewerNavigationBarState extends State<PageViewerNavigationBar> {
  bool previousVisible = false;
  bool nextVisible = true;

  @override
  void initState() {
    super.initState();
    widget.preloadPageController.addListener(() {
      int position = widget.preloadPageController.page.round();
      setState(() {
        if (position == 0) {
          previousVisible = false;
        } else {
          previousVisible = true;
        }
        if (position == widget.totalPages - 1) {
          nextVisible = false;
        } else {
          nextVisible = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Container container = Container(
      color: Theme.of(context).primaryColorLight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Visibility(
              visible: previousVisible,
              child: FlatButton(
                child: Text(
                  '< Prev',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  widget.previousHandler();
                },
              )),
          Visibility(
              visible: nextVisible,
              child: FlatButton(
                child: Text(
                  'Next >',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  widget.nextHandler();
                },
              ))
        ],
      ),
    );
    return container;
  }
}

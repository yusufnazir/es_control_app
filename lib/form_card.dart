import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:es_control_app/repository/db_provider.dart';
import 'package:es_control_app/survey_forms_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormCardTile extends StatefulWidget {
  final Function(Function callBack) prepareForUpload;
  final VoidCallback surveyFormSelected;
  final SurveyResponse surveyResponse;

  FormCardTile(
      {this.prepareForUpload,
      this.surveyFormSelected,
      this.surveyResponse,
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FormCardTileState();
  }
}

enum WhyFarther { removeAllData }

class FormCardTileState extends State<FormCardTile> {
//  bool uploaded = false;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateState() {
//      setState(() {
//        uploaded = !uploaded;
//      });
    }

    cloudClicked() async {
      await widget.prepareForUpload(updateState);
    }

    IconButton cloudBtn = IconButton(
        onPressed: () async {
//          if (!uploaded) {
          await cloudClicked();
//          } else {
//            Flushbar(duration: Duration(seconds: 3),
//              flushbarPosition: FlushbarPosition.TOP,
//              flushbarStyle: FlushbarStyle.FLOATING,
//              isDismissible: true,
//              dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//              title: "Already uploaded.",
//              message: "This form has already been uploaded.",
//              backgroundGradient: LinearGradient(
//                colors: [
//                  Constants.primaryColorLight,
//                  Constants.primaryColor
//                ],
//              ),
//              boxShadow: BoxShadow(
//                color: Colors.green[800],
//                offset: Offset(0.0, 2.0),
//                blurRadius: 3.0,
//              ),
//            )..show(context);
//          }
        },
        padding: EdgeInsets.all(0.0),
        color: Colors.white,
        icon: Icon(
          Icons.cloud_upload,
//          uploaded ? Icons.cloud_done : Icons.cloud_upload,
          color: Colors.white,
        ));

    return ListTile(
        key: _scaffoldKey,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24))),
          child: cloudBtn,
        ),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.surveyResponse.formName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22.0,
                ),
              ),
            ]),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.date_range, color: Colors.yellowAccent),
                Text(
                    " ${DateFormat(Constants.dateTimeFormat).format(widget.surveyResponse.createdOn)}",
                    style: TextStyle(color: Colors.white))
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                showRemoveAllDialog();
              },
              child: Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.red),
                    borderRadius: new BorderRadius.all(Radius.circular(10))),
//              color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Icon(Icons.remove_circle_outline, color: Colors.red),
                    Text("Remove all data".toUpperCase(),
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20))
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: widget.surveyFormSelected,
          icon: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white,
            size: 30.0,
          ),
          padding: EdgeInsets.all(0.0),
        )
//        trailing:Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0)
        );
  }

  void showRemoveAllDialog() {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: Text(
              "You will be removing all data for this form. Are you sure you want to continue?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            actions: <Widget>[
              Row(
                children: <Widget>[
                  FlatButton(
                    child: const Text('No',
                        style: TextStyle(fontSize: 30, color: Colors.green)),
                    onPressed: () {
                      Navigator.of(context).pop(ConfirmAction.CANCEL);
                    },
                  ),
                  FlatButton(
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop(ConfirmAction.ACCEPT);
                      await DBProvider.db
                          .removeAllFormData(widget.surveyResponse.uniqueId);
//                      await Flushbar(
//                        duration: Duration(seconds: 8),
//                        flushbarPosition: FlushbarPosition.TOP,
//                        flushbarStyle: FlushbarStyle.FLOATING,
//                        isDismissible: true,
//                        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
//                        title: "Data removed.",
//                        message:
//                            "You have sucessfully removed all data related to the form ${widget.surveyResponse.formName}.",
//                        backgroundGradient: LinearGradient(
//                          colors: [Colors.white, Colors.white],
//                        ),
//                        boxShadows: <BoxShadow>[
//                          BoxShadow(
//                            color: Colors.white,
//                            offset: Offset(0.0, 2.0),
//                            blurRadius: 3.0,
//                          )
//                        ],
//                      )..show(context);
                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              )
            ],
          );
        });
  }
}

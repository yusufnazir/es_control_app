import 'package:es_control_app/constants.dart';
import 'package:es_control_app/model/survey_response_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormCardTile extends StatefulWidget {
  final Function(Function callBack) prepareForUpload;
  final VoidCallback surveyFormSelected;
  final SurveyResponse surveyResponse;

  FormCardTile(
      {this.prepareForUpload, this.surveyFormSelected, this.surveyResponse, Key key}):super(key:key);

  @override
  State<StatefulWidget> createState() {
    return FormCardTileState();
  }
}

class FormCardTileState extends State<FormCardTile> {
//  bool uploaded = false;

  @override
  void initState() {
    super.initState();
//    uploaded = widget.surveyResponse.uploaded;
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
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
              border: new Border(
                  right: new BorderSide(width: 1.0, color: Colors.white24))),
          child: cloudBtn,
        ),
        title: Text(
          widget.surveyResponse.formName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22.0,
          ),
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Row(
          children: <Widget>[
            Icon(Icons.date_range, color: Colors.yellowAccent),
            Text(" ${DateFormat(Constants.dateFormat).format(widget.surveyResponse.createdOn)}",
                style: TextStyle(color: Colors.white))
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
}

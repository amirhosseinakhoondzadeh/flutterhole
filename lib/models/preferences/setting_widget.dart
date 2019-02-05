import 'package:flutter/material.dart';
import 'package:flutter_hole/models/dashboard/scan_button.dart';
import 'package:flutter_hole/models/preferences/preference.dart';
import 'package:flutter_hole/models/preferences/preference_form.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingWidget extends StatefulWidget {
  final Preference preference;
  final bool addScanButton;

  const SettingWidget(
      {Key key, @required this.preference, this.addScanButton = false})
      : super(key: key);

  @override
  SettingWidgetState createState() {
    return new SettingWidgetState();
  }
}

class SettingWidgetState extends State<SettingWidget> {
  Future onHelpTap(BuildContext context, Widget help) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(widget.preference.title),
            content: help,
          );
        });
  }

  Future onPrefTap(AsyncSnapshot<String> snapshot, BuildContext context,
      TextEditingController controller) {
    final _formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          final preferenceForm = PreferenceForm(
            formKey: _formKey,
            controller: controller,
          );
          return alertPrefDialog(
              preferenceForm, context, controller, widget.preference.onSet);
        });
  }

  AlertDialog alertPrefDialog(PreferenceForm preferenceForm,
      BuildContext context, TextEditingController controller, Function onSet) {
    List<Widget> actions = [
      FlatButton(
        child: Text('Cancel'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      FlatButton(
        child: Text('OK'),
        onPressed: () {
          if (preferenceForm.formKey.currentState.validate()) {
            widget.preference.set(controller.text, context).then((bool didSet) {
              if (onSet != null) {
                // Trigger rebuild with the newly edited controller.text
                setState(() {});
                onSet(didSet, context);
              }
            });
            Navigator.pop(context);
          }
        },
      )
    ];

    if (widget.addScanButton != null && widget.addScanButton) {
      actions.insert(0, ScanButton(controller: controller));
    }

    return AlertDialog(
      title: Text(widget.preference.title),
      content: preferenceForm,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: widget.preference.get(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            final controller = TextEditingController(text: snapshot.data);
            return ListTile(
              leading: Icon(widget.preference.iconData),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(widget.preference.title),
                  IconButton(
                    icon: Icon(
                      Icons.help_outline,
                      color: Colors.grey,
                      size: 16.0,
                    ),
                    onPressed: () => onHelpTap(context, widget.preference.help),
                  )
                ],
              ),
              subtitle: Text(controller.text),
              onTap: () {
                return onPrefTap(snapshot, context, controller);
              },
              onLongPress: () {
                Fluttertoast.instance
                    .showToast(msg: widget.preference.description);
              },
            );
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}

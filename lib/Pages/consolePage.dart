import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:loda/Pages/changeFont.dart';
import 'package:loda/Pages/locale.dart';
import 'package:loda/Pages/pickTheme.dart';
import 'package:loda/Pages/removeData.dart';
import 'package:loda/Themes/theme_manager.dart';
import 'package:loda/Widgets/Console/consoleButton.dart';
import 'package:loda/Widgets/Console/userTasksWidget.dart';
import 'package:loda/Widgets/dialogs.dart';
import 'package:loda/model/Logic/ChangeFont/changeFontLogic.dart';
import 'package:loda/model/database/todomodel.dart';
import 'package:provider/src/provider.dart';

import 'package:url_launcher/url_launcher.dart';

class ConsolePage extends StatefulWidget {
  @override
  State<ConsolePage> createState() => _ConsolePageState();
}

class _ConsolePageState extends State<ConsolePage> {
  TextEditingController _textEditingController = TextEditingController();
  ScrollController _scrollConsoleController =
      ScrollController(initialScrollOffset: 0);
  @override
  void initState() {
    super.initState();

    context.read<ChangeFontLogic>().fontSize =
        userDataBox.get('currentFontSize');
    _scrollConsoleToLast();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _scrollConsoleToLast() {
//FIXED   ScrollController not attached to any scroll views.
    if (_scrollConsoleController.hasClients) {
      if (Hive.box<TodoModel>('user_reports').values.isEmpty) {
        print('dont scrooll');
      } else if (Hive.box<TodoModel>('user_reports').values.isNotEmpty) {
        _scrollConsoleController
            .jumpTo(_scrollConsoleController.position.maxScrollExtent);
        print('can scroll');
      }
    }
  }

  _saveData() async {
    if (_textEditingController.text.length >= 2) {
      await Hive.box<TodoModel>('user_reports').add(TodoModel(
          date: DateFormat('yMd').format(DateTime.now()).toString(),
          text: _textEditingController.text));
      print('saved!');
      _textEditingController.text = '';
    }
  }

  DateTime _timeNow = DateTime.now();
  var userDataBox = Hive.box('user_data');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.85, // 86
            width: double.infinity,
            child: ValueListenableBuilder(
                valueListenable:
                    Hive.box<TodoModel>('user_reports').listenable(),
                builder: (context, Box<TodoModel> box, _) {
                  if (box.values.isEmpty) {
                    return Center(
                        child: Text(
                      'EmptyList'.tr() + ' \😔',
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ));
                  } else {
                    return ListView.builder(
                        controller: _scrollConsoleController,
                        itemCount: box.length,
                        shrinkWrap: true,
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          TodoModel? todo = box.getAt(index);
                          return UserMessage(
                            fontSize: context.watch<ChangeFontLogic>().fontSize,
                            date: todo!.date.toString(),
                            text: todo.text ?? "null",
                            userName: userDataBox.get('nickname') ?? "null",
                          );
                        });
                  }
                }),
          ),

          // down side
          DraggableScrollableSheet(
              expand: true,
              initialChildSize: 0.14,
              minChildSize: 0.14,
              maxChildSize: 0.5,
              builder: (BuildContext context, controller) {
                return Material(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14)),
                  color: context.watch<ThemeManager>().sheetColor,

                  //Provider.of<ThemeManager>(context,listen: true).sheetColor,
                  child: SingleChildScrollView(
                    // physics: PageScrollPhysics(),
                    controller: controller,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 155, vertical: 9),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .color,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        Text(
                          'Today'.tr() +
                              ' ${DateFormat('yMd').format(_timeNow)}',
                          softWrap: true,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                              fontSize: 15),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            LimitedBox(
                              // maxWidth: MediaQuery.of(context).size.height * 0.1,
                              maxWidth: 250,
                              child: TextField(
                                maxLines: 1,
                                
                                controller: _textEditingController,
                                autocorrect: true,
                                cursorWidth: 8,
                                cursorColor: Theme.of(context).buttonColor,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIconColor:
                                      Theme.of(context).primaryColor,
                                  hintText: 'DayExperience'.tr(),
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).buttonColor,
                                  ),
                                  focusColor: Theme.of(context).buttonColor,
                                  hoverColor: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _saveData(),
                                splashColor: Theme.of(context).buttonColor,
                                child: Icon(
                                  Icons.send,
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            // InkWell(
                            //   onTap: () => _listen(),
                            //   child: Icon(
                            //     _isListening ? Icons.mic : Icons.mic_none,
                            //     color: Theme.of(context).buttonColor,
                            //   ),
                            // ),
                          ],
                        ),
                        // buttons
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Wrap(
                            runSpacing: 25,
                            spacing: 0,
                            alignment: WrapAlignment.center,
                            children: [
                              // ConsoleButton(
                              //   leadingIcon: Icons.supervised_user_circle,
                              //   title: 'User',
                              //   onclick: () => null,
                              // ),
                              ConsoleButton(
                                leadingIcon: Icons.grid_4x4_outlined,
                                title: 'GridView'.tr(),
                                onclick: () => null,
                              ),

                              ConsoleButton(
                                leadingIcon: Icons.style,
                                title: 'Themes'.tr(),
                                onclick: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SwitchThemePage())),
                              ),
                              ConsoleButton(
                                leadingIcon: Icons.format_size,
                                title: 'FontSize'.tr(),
                                onclick: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ChangeFont())),
                              ),
                              // CustomButton1(
                              //   leadingIcon: Icons.timeline,
                              //   title: 'Stats',
                              //   onclick: () => null,
                              // ),
                              ConsoleButton(
                                leadingIcon: Icons.star,
                                title: 'RateApp'.tr(),
                                onclick: () => null,
                              ),
                              ConsoleButton(
                                  leadingIcon: Icons.delete,
                                  title: 'EraseData'.tr(),
                                  onclick: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RemoveData()));
                                  }),
                              ConsoleButton(
                                leadingIcon: Icons.translate,
                                title: 'Lang'.tr(),
                                onclick: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => LocalePage())),
                              ),
                              ConsoleButton(
                                leadingIcon: Icons.power_settings_new,
                                title: 'Exit'.tr(),
                                onclick: () => exit(0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}

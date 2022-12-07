import 'dart:math';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:loga/database/scheme/db_scheme.dart';
import 'package:loga/screens/register_screen/controller/generated_nicknames.dart';
import 'package:loga/screens/console_screen/console_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:loga/screens/register_screen/widgets/text_field.dart';
import 'package:parallax_rain/parallax_rain.dart';
import 'package:random_string/random_string.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _errorhandler = '';
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _nicknameStatus = false;
  bool _passwordStatus = false;
  Box _userDataStorage = Hive.box(DbScheme.userData);
  String _verification() {
    if (_formKey.currentState!.validate()) {
      if (_nicknameController.text.length >= 2 &&
          _passwordController.text.length >= 7) {
        _userDataStorage.put(DbScheme.nickname, _nicknameController.text);
        _userDataStorage.put(DbScheme.password, _passwordController.text);
        print('Username: ${_nicknameController.text}');
        print('Password: ${_passwordController.text}');
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ConsoleScreen()),
        );
        return 'Saved data!';
      } else if (_nicknameController.text == '' &&
          _passwordController.text == '') {
        return 'Fields cant be empty.';
      } else if (_nicknameController.text == '') {
        return 'Nickname cant be empty.';
      } else if (_passwordController.text == '') {
        return 'Password cant be empty.';
      } else if (_nicknameController.text.length <= 2) {
        return 'Too short nickname. Nickname must be >2 symbols.';
      } else if (_passwordController.text.length <= 8) {
        return 'Too short password. Password must be >10 symbols.';
      }
    }
    return '.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ParallaxRain(
          dropFallSpeed: 1.60,
          dropHeight: 10,
          numberOfDrops: 300,
          dropColors: const [
            Colors.green,
            Colors.greenAccent,
          ],
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _logo(),
                  RegisterTextField(
                    hintText: 'Nickname'.tr(),
                    textEditingController: _nicknameController,
                    maxLength: 20,
                  ),
                  RegisterTextField(
                    hintText: 'Password'.tr(),
                    textEditingController: _passwordController,
                    maxLength: 20,
                  ),
                  Text(
                    _errorhandler,
                    style: TextStyle(color: Colors.red),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GenerateNickname'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      StatefulBuilder(builder: (context, state) {
                        return CupertinoSwitch(
                          thumbColor: Theme.of(context).scaffoldBackgroundColor,
                          value: _nicknameStatus,
                          onChanged: (value) {
                            state(() {
                              _nicknameStatus = value;
                              if (_nicknameStatus) {
                                _nicknameController.text =
                                    GeneratedNicknames.nickNamesList[Random()
                                        .nextInt(GeneratedNicknames
                                            .nickNamesList.length)];
                              } else {
                                _nicknameController.text = '';
                              }
                            });
                          },
                          activeColor: Colors.white,
                        );
                      }),
                      // CupertinoSwitch(
                      //   thumbColor: Theme.of(context).scaffoldBackgroundColor,
                      //   value: _nicknameStatus,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _nicknameStatus = value;
                      //       if (_nicknameStatus) {
                      //         _nicknameController.text =
                      //             GeneratedNicknames.nickNames[Random().nextInt(
                      //                 GeneratedNicknames.nickNames.length)];
                      //       } else {
                      //         _nicknameController.text = '';
                      //       }
                      //     });
                      //   },
                      //   activeColor: Colors.white,
                      // ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GeneratePassword'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      StatefulBuilder(builder: (context, state) {
                        return CupertinoSwitch(
                          value: _passwordStatus,
                          onChanged: (value) {
                            state(() {
                              _passwordStatus = value;
                              if (_passwordStatus) {
                                _passwordController.text = randomString(8);
                              } else {
                                _passwordController.text = '';
                              }
                            });
                          },
                          thumbColor: Theme.of(context).scaffoldBackgroundColor,
                          activeColor: Colors.white,
                        );
                      }),
                    ],
                  ),
                  // enter
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _errorhandler = _verification();
                      });
                    },
                    child: Text(
                      'Enter'.tr(),
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // decoration: BoxDecoration(
          //     image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(''))),
        ),
      ),
    );
  }
}

Widget _logo() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 50),
    child: Column(
      children: [
        Image.asset('assets/logo.png'),
        const Text(
          'Your awesome\n        day logger',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ],
    ),
  );
}
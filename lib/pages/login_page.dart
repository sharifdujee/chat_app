import 'package:chat_app/pages/home_pages.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/shared/consts.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  static String route = "/login";
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  String? _email;
  String? _password;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [_headerText(), _loginForm(), _createAccountLink()],
      ),
    ));
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Hi, Welcome Back!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          Text(
            "Hello again, you've been missed",
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 15),
          )
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05),
      child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomFormField(
                validationRegEx: EMAIL_VALIDATION_REGEX,
                controller: emailController,
                height: MediaQuery.sizeOf(context).height * 0.1,
                labelText: 'Email',
                hintText: 'sharifdu44@gmail.com',
                onSaved: (value) {
                  setState(() {
                    _email = value!;
                  });
                },
              ),
              CustomFormField(
                onSaved: (value) {
                  setState(() {
                    _password = value!;
                  });
                },
                obscureText: true,
                validationRegEx: PASSWORD_VALIDATION_REGEX,
                controller: passwordController,
                height: MediaQuery.sizeOf(context).height * 0.1,
                labelText: 'Password',
                hintText: '@!32dggg%&',
              ),
              _loginButton()
            ],
          )),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(_email!, _password!);
            print(result);
            if (result) {
              _navigationService.pushReplacementNamed('/home');
            } else {
              _alertService.showToast(text: 'Failed to login, Please try later!',
              icon: Icons.error);
            }
          }
          ;
        },
        color: Theme.of(context).colorScheme.primary,
        child: const Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _createAccountLink() {
    return Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Don't have an account? "),
        GestureDetector(
          onTap: (){
            _navigationService.pushNamed('/register');
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        )
      ],
    ));
  }
}

import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePages extends StatefulWidget {
  static String route = '/home';
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Messages'),
        actions: [
          IconButton(
              onPressed: () async {
                bool result = await _authService.logout();
                if (result) {
                  _alertService.showToast(
                      text: 'Successfully Logged out!', icon: Icons.check);
                  _navigationService.pushReplacementNamed('/login');
                }
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ))
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
        child: _chatList(),
      ),
    );
  }

  Widget  _chatList(){
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Center(
            child: Text('Unable to Load Data'),
          );
        }
        print(snapshot.data);
        if(snapshot.hasData && snapshot.data !=null){
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
              itemBuilder: (context, index){
              UserProfile user = users[index].data();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ChatTile(userProfile: user, onTap: () async{

                  final chatExists = await _databaseService.checkChatExists(_authService.user!.uid, user.uid!);
                  if(!chatExists){
                    await _databaseService.createNewChat(_authService.user!.uid, user.uid!);

                  }
                  _navigationService.puss(MaterialPageRoute(builder: (context)=>  ChatPage(chatUser: user)));


                }),
              );

          });

        }
        return const Center(
          child: CircularProgressIndicator(),

        );
      },

    );

  }
}

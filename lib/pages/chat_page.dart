import 'dart:io';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/utils/uttils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get_it/get_it.dart';

import '../models/chat.dart';
class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  ChatUser? currentUser, otherUser;
  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(id: widget.chatUser.uid!, firstName: widget.chatUser.name!,
      profileImage: widget.chatUser.pfpURL!
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.chatUser.name!),
      ),
      body: _buildUI(),

    );
  }
  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if(chatMessage.medias?.isNotEmpty?? false){
      if(chatMessage.medias!.first.type == MediaType.image){
        Message message = Message(senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendChatMessage(currentUser!.id, otherUser!.id, message);

      }

    }
    else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );


      // Sending the message to Firestore
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);

      // Add the message to the local list if needed
      /*setState(() {
      //messages.add(chatMessage);
    });*/
    }
  }
  List<ChatMessage> _generatedChatMessageList(List<Message> messages){
    List<ChatMessage> chatMessages = messages.map((m){
      if(m.messageType == MessageType.Image){
        return ChatMessage(user: m.senderID == currentUser!.id ? currentUser!:otherUser!,
          medias: [
            ChatMedia(url: m.content!, fileName: "", type: MediaType.image)
          ],
          createdAt: m.sentAt!.toDate(),);

      }
      else{
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser!:otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate(),);

      }


  }).toList();
    chatMessages.sort((a,b){
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _buildUI() {

    return StreamBuilder(stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshot){
         Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];
          if(chat != null && chat.messages!=null){
            messages = _generatedChatMessageList(chat.messages!);

          }
          return DashChat(
            messageOptions: const MessageOptions(
              showTime: true,
              showOtherUsersAvatar: true
            ),
              inputOptions:  InputOptions(
                alwaysShowSend: true,
                trailing: [
                  _mediaMessageButton(),
                ]
              ),
              currentUser: currentUser!, onSend: _sendMessage, messages: messages);


        });



      
  }
  Widget _mediaMessageButton(){
    return IconButton(onPressed: ()async {
    File? file = await  _mediaService.getImageFromGallery();
    if(file!=null){
      String chatID= generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
     String? downLoadUrl = await  _storageService.uploadingImageToChat(file: file, chatID: chatID);

     if(downLoadUrl!=null){
       ChatMessage chatMessage = ChatMessage(user: currentUser!, createdAt: DateTime.now(), medias: [ChatMedia(url: downLoadUrl, fileName: "fileName", type: MediaType.image)]);
       _sendMessage(chatMessage);
     }

    }
    }, icon: Icon(Icons.image,
    color: Theme.of(context).colorScheme.primary,));
  }

}

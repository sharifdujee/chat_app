import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';
class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  StorageService() {}

  Future<String?> uploadUserPfp({required File file, required String uid}) async{
    Reference fileRef = _firebaseStorage.ref('user/pfps').child('$uid${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then((p){
      if(p.state == TaskState.success){
        return fileRef.getDownloadURL();
      }
    });


  }

  Future<String?> uploadingImageToChat({required File file, required String chatID}) async{
    Reference fileRef = _firebaseStorage.ref('chats/$chatID').child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then((p){
      if(p.state == TaskState.success){
        return fileRef.getDownloadURL();
      }

    });


  }
}

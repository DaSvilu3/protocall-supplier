import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadMediatoFB {
  Future<Map> photoOption(type) async {
    String downloadableUrl = "";
    try {
      final Reference _storage = FirebaseStorage().ref().child(
          (type == 0 ? "images" : "videos") + "/" + Uuid().v4().toString());
      final _picker = ImagePicker();

      PickedFile image = type == 0
          ? await _picker.getImage(source: ImageSource.gallery)
          : await _picker.getVideo(source: ImageSource.gallery);

      if (image == null) {
        return null;
      }
      final File file = File(image.path);
      print("i reach this");

      final UploadTask uploadTask = _storage.putFile(file);
      print("i reach this");
//      final StreamSubscription<Task> streamSubscription =
//          uploadTask.events.listen((event) {
//        print('EVENT ${event.type}');
//      });
      await uploadTask.whenComplete(() => null);
      final downloadUrl = await (await uploadTask.whenComplete(() => null))
          .ref
          .getDownloadURL();
      var thumnailUri =
          file.parent.path + "/" + Uuid().v4().toString() + '.png';

      if (type == 0) {
        var decodedImage = img.decodeImage(file.readAsBytesSync());
        var thumbnail = img.copyResize(decodedImage, width: 200);
        await File(thumnailUri).writeAsBytesSync(img.encodePng(thumbnail));
      } else {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth:
              250, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 100,
        );
        await File(thumnailUri).writeAsBytesSync(uint8list);
      }

      File thum = File(thumnailUri);
      final Reference _storage2 = FirebaseStorage().ref().child("/thumb/" +
          (type == 0 ? "images/" : "videos/") +
          Uuid().v4().toString());

      final UploadTask uploadTask2 = _storage2.putFile(thum);
//      final StreamSubscription<Event> streamSubscription2 =
//          uploadTask2.events.listen((event) {
//        print('EVENT ${event.type}');
//      });
      await uploadTask2.whenComplete(() => null);
      final downloadUrl2 = await (await uploadTask2.whenComplete(() => null))
          .ref
          .getDownloadURL();
//      streamSubscription.cancel();
//      streamSubscription2.cancel();

      return {"main": downloadUrl.toString(), "thumb": downloadUrl2};
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

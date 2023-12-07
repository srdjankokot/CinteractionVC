
class ImageData{
   int call_id;
   int participant_id;
   String image;

   ImageData(this.call_id, this.participant_id, this.image);

   Map<String, dynamic> toJson() =>
       {
          'call_id': call_id,
          'participant_id': participant_id,
          'image': image,
       };
}


class ImageDataList{
  List<ImageData> images;

  ImageDataList(this.images);

  Map<String, dynamic> toJson() =>
      {
        'images': images,
      };
}
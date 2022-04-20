import 'dart:ffi';

class DataModel{
  double longitude;
  //String image;
  double latitude;
  int vitesse;


  DataModel.fromJson(Map<String,dynamic> json)
      : longitude = json['longitude'],
  //image = json['logo_url'],
        latitude = json['latitude'],
        vitesse = json['vitesse'];

  // Converting object to json

  Map<String, dynamic>toJson() => {
    'longitude' : longitude,
    /*'logo_url' : image,*/
    'latitude' : latitude,
    'vitesse' : vitesse
  };
}
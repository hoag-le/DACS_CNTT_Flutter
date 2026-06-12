class UserModel {
  String? uid;
  int? id;
  String? username;
  String? email;
  String? fullname;
  String? phonenumber;
  String? birthday;
  int? role;
  int? status;
  String? googleId;
  String? loginType;

  UserModel({
    this.uid,
    this.id,
    this.username,
    this.email,
    this.fullname,
    this.phonenumber,
    this.birthday,
    this.role,
    this.status,
    this.googleId,
    this.loginType,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'] as String?;
    id = (json['id'] as num?)?.toInt();
    username = json['username'] as String?;
    email = json['email'] as String?;
    fullname = json['fullname'] as String?;
    phonenumber = json['phonenumber'] as String?;
    birthday = json['birthday'] as String?;
    role = (json['role'] as num?)?.toInt();
    status = (json['status'] as num?)?.toInt();
    googleId = json['googleId'] as String? ?? json['google_id'] as String?;
    loginType = json['loginType'] as String? ?? json['login_type'] as String?;
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'fullname': fullname,
      'phonenumber': phonenumber,
      'birthday': birthday,
      'role': role ?? 0,
      'status': status ?? 1,
      'googleId': googleId,
      'loginType': loginType ?? 'local',
    };
  }
}

class UserModel {
  String? uid;
  int? id;
  String? username;
  String? email;
  String? fullname;
  String? phonenumber;
  String? birthday;
  String? password;
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
    this.password,
    this.role,
    this.status,
    this.googleId,
    this.loginType,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    id = json['id'];
    username = json['username'];
    email = json['email'];
    fullname = json['fullname'];
    phonenumber = json['phonenumber'];
    birthday = json['birthday'];
    password = json['password'];
    role = json['role'];
    status = json['status'];
    googleId = json['google_id'];
    loginType = json['login_type'] ?? json['loginType'];
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
      'google_id': googleId,
      'login_type': loginType ?? 'local',
    };
  }
}

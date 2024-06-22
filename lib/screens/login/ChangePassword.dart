import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin/DashboardAdmin.dart';
import '../../nodejs/rest_api.dart';
import '../../prof/DashboardProf.dart';
import '../../student/DashboardStudent.dart';

class ChangePassword extends StatefulWidget {
  final Map<String, dynamic>? user;

  ChangePassword({Key? key, this.user}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.black,
              ],
              stops: [0.0, 1.0],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.lightBlue.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo.jpg',
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Change Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisibility,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              labelStyle: TextStyle(
                                color: Colors.blueGrey.shade500,
                                fontFamily: 'Tahoma',
                                letterSpacing: 0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueGrey.shade500,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueGrey.shade500,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueGrey.shade500,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white30,
                              suffixIcon: InkWell(
                                onTap: () => setState(() {
                                  _passwordVisibility = !_passwordVisibility;
                                }),
                                focusNode: FocusNode(skipTraversal: true),
                                child: Icon(
                                  _passwordVisibility
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.blueGrey.shade500,
                                  size: 24,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a new password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_confirmPasswordVisibility,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(
                                color: Colors.blueGrey.shade500,
                                fontFamily: 'Tahoma',
                                letterSpacing: 0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueGrey.shade500,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueGrey.shade500,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueGrey.shade500,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white30,
                              suffixIcon: InkWell(
                                onTap: () => setState(() {
                                  _confirmPasswordVisibility = !_confirmPasswordVisibility;
                                }),
                                focusNode: FocusNode(skipTraversal: true),
                                child: Icon(
                                  _confirmPasswordVisibility
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.blueGrey.shade500,
                                  size: 24,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                var res = await updatePassword(
                                    widget.user!['id'], _passwordController.text);
                                if (res['success']) {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool('first_login', false);

                                  if (widget.user!['role'] == "prof") {
                                    Route route = MaterialPageRoute(
                                        builder: (_) => DashboardProf(user: widget.user));
                                    Navigator.pushReplacement(context, route);
                                  } else if (widget.user!['role'] == "student") {
                                    Route route = MaterialPageRoute(builder: (_) =>
                                        DashboardStudent(user: widget.user));
                                    Navigator.pushReplacement(context, route);
                                  } else if (widget.user!['role'] == "admin") {
                                    Route route = MaterialPageRoute(builder: (_) =>
                                        DashboardAdmin(user: widget.user));
                                    Navigator.pushReplacement(context, route);
                                  }
                                } else {
                                  Fluttertoast.showToast(msg: 'Failed to update password',
                                      textColor: Colors.red);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 108, 169, 200),
                              padding: EdgeInsets.zero,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              height: 44,
                              alignment: Alignment.center,
                              child: const Text(
                                'Update Password',
                                style: TextStyle(
                                  fontFamily: 'Readex Pro',
                                  color: Colors.white,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
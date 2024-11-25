import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/AuthProvider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

    final OutlineInputBorder whiteBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: Colors.white, width: 2),
    );

  bool _showPassword = false;
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectRole;
  final _formKey = GlobalKey<FormState>();

  String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Container(
          color: Colors.red[700],
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: SingleChildScrollView(
                child:Form(
                  key: _formKey,
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "HUST",
                      style: TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Welcome to AllHust",
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Họ", _surnameController
                          ),
                          flex: 4,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: _buildTextField("Tên", _nameController),
                          flex: 6,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildTextField("Email", _emailController),
                    SizedBox(
                      height: 20,
                    ),
                    _buildPasswordField("Password", _passwordController ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildRoleField(),
                    SizedBox(
                      height: 30,
                    ),
                    if (authProvider.isLoading) const CircularProgressIndicator()
                    ,SizedBox(width: 20,),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        authProvider.signUp(context,_surnameController.text, _nameController.text ,_emailController.text, _passwordController.text, selectRole!);
                      }

                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700]),
                    )),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/signin");
                        },
                        child: Text(
                          "Login with account",
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
              ),)
            ),
          )),
    );
  }


  Widget _buildTextField(String text, TextEditingController textedit) {
    return TextFormField(
      controller: textedit,
      validator: (value)=> validateNotEmpty(value, text),
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: text,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        enabledBorder: whiteBorder,
        focusedBorder: whiteBorder,
        disabledBorder: whiteBorder,
        errorBorder: whiteBorder, // Viền màu đỏ khi có lỗi
        focusedErrorBorder: whiteBorder,
      ),
    );
  }

  Widget _buildPasswordField(String text, TextEditingController textedit) {
    return TextFormField(
      controller: textedit,
      style: TextStyle(color: Colors.white),
      validator: (value) => validateNotEmpty(value, text),
      obscureText: !_showPassword,
      decoration: InputDecoration(
        labelText: text,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
          enabledBorder: whiteBorder,
          focusedBorder: whiteBorder,
          disabledBorder: whiteBorder,
          errorBorder: whiteBorder, // Viền màu đỏ khi có lỗi
          focusedErrorBorder: whiteBorder,
        suffixIcon: IconButton(
            onPressed: (){
              setState(() {
                _showPassword = ! _showPassword;
              });
            },
            icon: Icon(
              _showPassword ? Icons.visibility: Icons.visibility_off,
              color: Colors.white,
            ))
      ),
    );
  }

  Widget _buildRoleField() {
    return DropdownButtonFormField<String>(
      style: TextStyle(color: Colors.white),
      validator: (value)=> validateNotEmpty(value, "Role"),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        enabledBorder: whiteBorder,
        focusedBorder: whiteBorder,
        disabledBorder: whiteBorder,
        errorBorder: whiteBorder, // Viền màu đỏ khi có lỗi
        focusedErrorBorder: whiteBorder,
      ),
      items: ['STUDENT', 'LECTURER'].map((String role) {
        return DropdownMenuItem(
          child: Text(
            role,
            style: TextStyle(color: Colors.white),
          ),
          value: role,
        );
      }).toList(),
      onChanged: (String? role) {
        setState(() {
          selectRole = role;
          print(selectRole);
        });
      },
      hint: Text(
        'Role',
        style: TextStyle(color: Colors.white),
      ),
      dropdownColor: Colors.red[700],
      isExpanded: true,
    );
  }

}
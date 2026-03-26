import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_happens/core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFBFAF9),
      appBar: AppBar(
        title: const Text('Реєстрація'),
        backgroundColor: const Color(0xFFFBFAF9),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/events');
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Логотип
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F0ED),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF79867D),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: Image.asset('lib/assets/images/logo.png'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text('LocalHappens', style: AppTextStyles.headline),
                  const SizedBox(height: 2),
                  const Text(
                    'Знаходь цікаве поруч',
                    style: AppTextStyles.value,
                  ),

                  const SizedBox(height: 42),

                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Ваше ім’я',
                          ),
                          validator: Validators.validateName,
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: Validators.validateEmail,
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.go,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Пароль',
                          ),
                          validator: Validators.validatePassword,
                          onFieldSubmitted: (_) {
                            _submitForm();
                          },
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Зареєструватися'),
                        ),

                        if (state is AuthLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

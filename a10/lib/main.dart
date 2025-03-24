import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Validation Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SignupScreen(),
    );
  }
}

// Signup Screen
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _submitForm() {
    if (_formKey.currentState!.saveAndValidate()) {
      // Get Form Data
      final formData = _formKey.currentState!.value;
      
      // Navigate to Confirmation Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(formData: formData),
        ),
      );
    } else {
      // Show error message if form is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Validation Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username Field
              FormBuilderTextField(
                name: 'Username:',
                decoration: const InputDecoration(labelText: 'Username',icon:Icon(Icons.people)),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.username(),
                ]),
              ),
              const SizedBox(height: 10),

              // Email Field
              FormBuilderTextField(
                name: 'Email:',
                decoration: const InputDecoration(labelText: 'Email Address',icon:Icon(Icons.email)),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              const SizedBox(height: 10),

              // Date of Birth Field
              FormBuilderDateTimePicker(
                name: 'DOB:',
                inputType: InputType.date,
                decoration: const InputDecoration(labelText: 'Date of Birth',icon:Icon(Icons.calendar_month)),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              const SizedBox(height: 10),

              // Password Field
              FormBuilderTextField(
                name: 'Password:',
                decoration: const InputDecoration(labelText: 'Password',icon:Icon(Icons.password)),
                obscureText: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.password(),
                ]),
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Confirmation Screen
class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> formData;

  const ConfirmationScreen({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup Successful')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signup Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Username: ${formData['username']}'),
            Text('Email: ${formData['email']}'),
            Text('Date of Birth: ${formData['dob']}'),
            const SizedBox(height: 20),

            // Back to Home Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomStepper extends StatefulWidget {
  const CustomStepper({Key? key}) : super(key: key);

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  int currentStep = 0;
  static const platform = MethodChannel('com.naeem.stepper/data');
  String currentDescription = "";

  final List<String> steps = [
    "Select campaign settings",
    "Create an ad group",
    "Create an ad",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Stepper"),
      ),
      body: Stepper(
        currentStep: currentStep,
        controlsBuilder: (_, details) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(isCompleted ? "FINISH" : 'CONTINUE'),
              ),
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('BACK'),
              ),
            ],
          );
        },
        onStepContinue: () {
          if (isCompleted) {
            print("Finished");
            return;
          }

          setState(() {
            currentStep++;
          });
          getDescription();
        },
        onStepCancel: currentStep == 0
            ? null
            : () {
                setState(() {
                  currentStep--;
                });
                getDescription();
              },
        steps: steps.map((e) {
          int index = steps.indexOf(e);
          return Step(
            title: Text(
              e,
            ),
            isActive: currentStep >= index,
            state: currentStep > index ? StepState.complete : StepState.indexed,
            content: Text(
              currentDescription,
            ),
          );
        }).toList(),
      ),
    );
  }

  bool get isCompleted => (steps.length - 1) == currentStep;

  Future<void> getDescription() async {
    String description = "";
    try {
      final String result = await platform.invokeMethod('getData', currentStep);
      description = result;
    } on PlatformException catch (e) {
      description = "Failed to Invoke: '${e.message}'.";
    }
    setState(() {
      currentDescription = description;
    });
  }

  @override
  void initState() {
    getDescription();
    super.initState();
  }
}

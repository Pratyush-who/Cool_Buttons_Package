import 'package:flutter/material.dart';
import 'package:cool_buttons/cool_buttons.dart';

void main() => runApp(const ButtonDemoApp());

class ButtonDemoApp extends StatelessWidget {
  const ButtonDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Cool Buttons Demo')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          
                          ShimmerButton(
                            text: "Shmer",
                            onTap: () => print("Tapped!"),
                          ),
                          const SizedBox(height: 20),
                          SleekOutlinedButton(
                            text: "Sleek",
                            onTap: () => print("Sleek!"),
                          ),
                          const SizedBox(height: 20),
                          RoboticRevolvingButton(
                            text: "Revolve",
                            lineColor: Colors.yellowAccent,
                            onTap: () => print("Revolve tapped"),
                            textColor: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          AnimatedDeleteButton(
                            onDelete: () => print("Delete tapped"),
                          ),
                          const SizedBox(height: 20),
                          AnimatedGetStartedButton(
                            text: "Get Started",
                            onTap: () => print("Get Started tapped"),
                          ),
                          const SizedBox(height: 20),
                          CompleteOrderButton(
                            text: "Complete Order",
                            width: 200,
                            onPressed: () => print("Complete Order tapped"),
                          ),
                          const SizedBox(height: 20),
                          CheckoutButton(
                            width: 210,
                            text: "Checkout",
                            onPressed: () => print("Checkout tapped"),
                          ),
                          const SizedBox(height: 20),
                          EpicCreatePostButton(
                            onPressed: () => print("Create a Post tapped"),
                            width: 210,
                            height: 60,
                          ),
                          const SizedBox(height: 20),
                          FuturisticButton(
                            text: "Futuristic",
                            onPressed: () => print("Lightning Border Button tapped"),
                            width: 210,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

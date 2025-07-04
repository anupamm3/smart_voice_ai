import 'package:flutter/material.dart';
import 'package:smart_voice_ai/feature_box.dart';
import 'package:smart_voice_ai/pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Smart Voice AI'),
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Virtual Assistant Image
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Pallete.assistantCircleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/virtualAssistant.png'),
                    ),
                  ),
                )
              ],
            ),
            //Greeting Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Pallete.borderColor,
                ),
                borderRadius: BorderRadius.circular(20).copyWith(
                  topLeft: Radius.zero,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'How can I help you?',
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    fontSize: 25,
                    color: Pallete.mainFontColor,
                  ),
                ),
              ),
            ),
            //Feature Text
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 10, left: 22),
              child: const Text('Here are a few features you can try:',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
            //Feature Boxes
            Column(
              children: [
                FeatureBox(
                  color: Pallete.featureBox1Color,
                  headerText: 'ChatGPT',
                  descriptionText: 'A smarter way to organize your thoughts and ideas with ChatGPT',
                ),
                FeatureBox(
                  color: Pallete.featureBox2Color,
                  headerText: 'Dall-E',
                  descriptionText: 'Get inspired and stay creative with your personal assistant powered by Dall-E',
                ),
                FeatureBox(
                  color: Pallete.featureBox3Color,
                  headerText: 'Smart Voice Assistant',
                  descriptionText: 'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to perform when the button is pressed
        },
        backgroundColor: Pallete.featureBox1Color,
        child: const Icon(Icons.mic),
      ),
    );
  }
}
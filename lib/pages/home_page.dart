import 'package:flutter/material.dart';
import 'package:music_tech/components/horizontal_slider.dart';
import 'package:music_tech/components/vertical_card.dart';
import 'package:music_tech/core/provider/audio_service_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  Future<void> onRefresh() async {
    try {
      setState(() {
        isLoading = true;
      });
      final audioServiceProvider = Provider.of<AudioServiceProvider>(
        context,
        listen: false,
      );
      await audioServiceProvider.getHomeSuggestion();
    } catch (e) {
      //
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final audioServiceProvider = Provider.of<AudioServiceProvider>(context);
    final homeData = audioServiceProvider.homeResults;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Home"),
          ),
          body: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...List.generate(homeData.length, (i) {
                    final record = homeData[i];
                    return HorizontalSlider(
                      title: record.title ?? "NA",
                      childrens: [
                        ...List.generate(record.contents.length, (i2) {
                          final record2 = record.contents[i2];

                          return VerticalCard(
                            record: record2,
                            list: record.contents,
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withAlpha(100),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

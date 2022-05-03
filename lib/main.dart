import 'dart:convert';
import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'package:system_theme/system_theme.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(800, 500);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "ImageToString";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        accentColor: SystemTheme.accentInstance.accent.toAccentColor(),
        brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

class ImageAndText {
  final String imagePath;
  final String text;

  ImageAndText({required this.imagePath, required this.text});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ImageAndText imageAndText = ImageAndText(imagePath: '', text: '');
  bool _isEditingText = true;
  TextEditingController _editingController = TextEditingController();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getImageAndText();
  }

  Future<void> getImageAndText() async {
    setState(() {
      isLoading = true;
    });
    var shell = Shell();
    var result = await shell.run('''
    python lens.py
    ''');
    var jsonResult = jsonDecode(result.outText);
    setState(() {
      imageAndText =
          ImageAndText(imagePath: jsonResult['path'], text: jsonResult['text']);
      _editingController = TextEditingController(text: imageAndText.text);
      isLoading = false;
    });
  }

  Future<void> grabImage() async {
    appWindow.minimize();
    var shell = Shell();

    await shell.run(''' 
    start/W ms-screenclip:
    ''');
    // print('await');
    getImageAndText();
    appWindow.restore();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      contentShape: const RoundedRectangleBorder(side: BorderSide.none),
      appBar: NavigationAppBar(
        height: 38,
        automaticallyImplyLeading: false,
        title: MoveWindow(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: const [
                Icon(
                  FluentIcons.image_search,
                  size: 22,
                  // color: Color.fromARGB(255, 218, 112, 214),
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  'O',
                  style: TextStyle(
                    fontSize: 22,
                    color: Color.fromARGB(255, 218, 112, 214),
                  ),
                ),
                Text(
                  ' Lens',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: MoveWindow(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              MinimizeWindowButton(
                  animate: true,
                  colors: WindowButtonColors(
                    iconNormal: Colors.white,
                  )),
              MaximizeWindowButton(
                  animate: true,
                  colors: WindowButtonColors(
                    iconNormal: Colors.white,
                  )),
              CloseWindowButton(
                  animate: true,
                  colors: WindowButtonColors(
                    iconNormal: Colors.white,
                    mouseOver: Colors.red,
                    // iconMouseOver: Colors.black,
                  )),
            ],
          ),
        ),
      ),
      pane: NavigationPane(
        displayMode: PaneDisplayMode.top,
        // header: Icon(FluentIcons.image_crosshair),
        items: [
          PaneItemAction(
            icon: const Icon(FluentIcons.desktop_screenshot),
            title: const Text('Take Screenshot'),
            onTap: () {
              grabImage();
            },
          ),
          PaneItemAction(
            icon: const Icon(FluentIcons.download_document),
            title: const Text('Grab Form ClipBoard'),
            onTap: () {
              getImageAndText();
            },
          ),
        ],
      ),
      content: isLoading
          ? const Center(child: ProgressRing())
          : imageAndText.imagePath.isEmpty
              ? const Center(
                  child: Text(
                  'No ClipboardImage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: InteractiveViewer(
                              minScale: 0.1,
                              maxScale: 10.0,
                              // boundaryMargin: EdgeInsets.all(50),
                              // constrained: false,
                              child: Image.file(File(imageAndText.imagePath))),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 4,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextBox(
                              readOnly: _isEditingText,
                              controller: _editingController,
                              maxLines: 20,
                              // child: material.SelectableText(
                              //   imageAndText.text.toString(),
                              //   style: TextStyle(fontSize: 20),
                              // ),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Button(
                                    child: Row(
                                      children: const [
                                        Icon(FluentIcons.copy),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Copy Text'),
                                      ],
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: _editingController.text));
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Button(
                                    child: Row(
                                      children: const [
                                        Icon(FluentIcons.edit),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Edit Text'),
                                      ],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isEditingText = false;
                                      });
                                    }),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

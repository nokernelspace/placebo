import 'package:flutter/material.dart';
import 'package:placebo/mood.dart';
import 'package:placebo/utils.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  Filesystem.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Placebo App',
      theme: ThemeData.dark(),
      home: MoodPage(),
    );
  }
}

class MoodPage extends StatefulWidget {
  @Preview(
    name: 'Mood Page Preview',
    textScaleFactor: 2.0,
    brightness: Brightness.dark,
  )
  MoodPage({super.key});

  final String title = "mood page";

  @override
  State<MoodPage> createState() => _MoodPageState();
}

// TODO: really confusing without `State`, add in it later
class _MoodPageState extends State<MoodPage> {
  var moods = Filesystem.collection("moods").sortedListSync();

  Mood current_mood = Mood();

  _MoodPageState() {
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(formatTime(current_mood.created_time)),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.newspaper),
              onPressed: () async {
                moods = Filesystem.collection("moods").sortedListSync();
                showModalBottomSheet(
                  isScrollControlled: true,
                  showDragHandle: true,
                  enableDrag: true,
                  context: context,
                  builder: (BuildContext context) {
                    return FractionallySizedBox(
                      heightFactor: 0.85,
                      child: ListView.separated(
                        itemBuilder: (BuildContext ctx, int idx) {
                          var mood = moods[idx]!;
                          var time = mood.created_time;
                          return ListTile(
                            title: Text(mood.people.name),
                            subtitle: Text(formatTime(time)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                mood.notes.length == 1
                                    ? Text(mood.notes[0])
                                    : Text("${mood.notes.length} Notes"),
                                Text(formatDate(time)),
                              ],
                            ),

                            onTap: () {
                              setState(() {
                                current_mood = mood;
                              });
                            },
                          );
                        },
                        separatorBuilder: (ctx, idx) {
                          return const SizedBox(
                            height: 1.0,
                            width: double.infinity,
                          );
                        },
                        itemCount: moods.length,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              current_mood.last_updated_time = DateTime.now();
              await Filesystem.collection("moods").add(
                current_mood.toJson(),
                // Need filename because we are not a datastore. Yet (•͡˘㇁•͡˘)
                sanitizeFilename(current_mood.created_time.toString()) +
                    ".mood",
              );
              showSnackBar(context, "Saved !");
            },
          ),
        ],
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 100),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Modes",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              ),

              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(75.0, 0.0, 75.0, 0.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Learning"),
                        SizedBox(width: 42),
                        Switch(
                          value: current_mood.modes.learning,
                          onChanged: (value) => setState(() {
                            current_mood.modes.learning = value;
                          }),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Physical"),
                        SizedBox(width: 42),
                        Switch(
                          value: current_mood.modes.physical,
                          onChanged: (value) => setState(() {
                            current_mood.modes.physical = value;
                          }),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Relax"),
                        SizedBox(width: 42),
                        Switch(
                          value: current_mood.modes.relax,
                          onChanged: (value) => setState(() {
                            current_mood.modes.relax = value;
                          }),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Working"),
                        SizedBox(width: 42),
                        Switch(
                          value: current_mood.modes.working,
                          onChanged: (value) => setState(() {
                            current_mood.modes.working = value;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Text(
                "Moods",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              ),

              Padding(
                padding: EdgeInsetsGeometry.all(7),
                child: Column(
                  children: [
                    const Text("Justice"),
                    Slider(
                      value: current_mood.justice,
                      onChanged: (value) => setState(() {
                        current_mood.justice = value;
                      }),
                    ),

                    const Text("Patience"),
                    Slider(
                      value: current_mood.patience,
                      onChanged: (value) => setState(() {
                        current_mood.patience = value;
                      }),
                    ),

                    const Text("Bravery"),
                    Slider(
                      value: current_mood.bravery,
                      onChanged: (value) => setState(() {
                        current_mood.bravery = value;
                      }),
                    ),

                    const Text("Integerity"),
                    Slider(
                      value: current_mood.integerity,
                      onChanged: (value) => setState(() {
                        current_mood.integerity = value;
                      }),
                    ),

                    const Text("Determination"),
                    Slider(
                      value: current_mood.determination,
                      onChanged: (value) => setState(() {
                        current_mood.determination = value;
                      }),
                    ),

                    const Text("Perseverence"),
                    Slider(
                      value: current_mood.perseverence,
                      onChanged: (value) => setState(() {
                        current_mood.perseverence = value;
                      }),
                    ),

                    const Text("Kindness"),
                    Slider(
                      value: current_mood.kindness,
                      onChanged: (value) => setState(() {
                        current_mood.kindness = value;
                      }),
                    ),
                  ],
                ),
              ),

              Text(
                "Notes",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              ),

              Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, idx) {
                      return Slidable(
                        startActionPane: ActionPane(
                          key: const ValueKey(0),
                          extentRatio: 0.5,
                          motion: const ScrollMotion(),

                          /// TODO: figure this out
                          // dismissible: DismissiblePane(
                          //   key: ValueKey(0),
                          //   onDismissed: () {}),
                          children: [
                            SlidableAction(
                              onPressed: (ctx) {
                                showCancelableMessageBox(
                                  ctx,
                                  "Delete?",
                                  "Are you sure you want to delete this bullet?",
                                  onConfirm: () {
                                    setState(() {
                                      current_mood.notes.removeAt(idx);
                                    });
                                    showSnackBar(
                                      context,
                                      "NOOOOOOOOOOOOOOOOOOOOOOO (屮ﾟДﾟ)屮",
                                    );
                                  },
                                  onCancel: () {},
                                );
                              },
                              icon: Icons.delete,
                              backgroundColor: Colors.red,
                              label: "delete",
                            ),
                            SlidableAction(
                              flex: 3,
                              onPressed: (ctx) {
                                TextEditingController controller =
                                    TextEditingController();
                                controller.text = current_mood.notes[idx];
                                showEditDialogBox(ctx, "Edit", controller, () {
                                  setState(() {
                                    current_mood.notes[idx] = controller.text;
                                  });
                                });
                              },
                              icon: Icons.edit,
                              backgroundColor: Colors.yellow,
                              label: "edit",
                            ),
                          ],
                        ),
                        child: ListTile(title: Text(current_mood.notes[idx])),
                        // child: ConstrainedBox(
                        //   constraints: BoxConstraints(minHeight: 50),
                        //   child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Hello World")]),
                        // ),
                      );
                    },
                    itemCount: current_mood.notes.length,
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        current_mood.notes.add("Slide to edit ➡");
                      });
                    },
                    icon: Icon(Icons.add),
                  ),

                  // TANG: Alfonzo >> Infinitly Sized Box >> ConstrainedBox => Default Constrains => Sized Box => Lines => †
                  SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(msg),
      // action: SnackBarAction(
      //     label: "Action",
      //     onPressed: () {}
      // ),
      behavior: .floating,
    ),
  );
}

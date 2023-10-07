import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vimars_kanani_room_practicle/room.dart';
import 'package:vimars_kanani_room_practicle/screen_extentions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Room Practical',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatelessWidget {
  RxList<Room> roomList = <Room>[].obs;
  RxnString roomCount = RxnString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            60.verticleSpace,
            SizedBox(
              width: Get.width,
              child: Obx(
                () => DropdownButton<String>(
                  items: List.generate(5, (index) => '${index + 1}')
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text('Room $e'),
                          ))
                      .toList(),
                  value: roomCount.value,
                  isExpanded: true,
                  hint: const Text('Select Room'),
                  onChanged: (value) {
                    roomCount.value = value;
                    generateRooms();
                  },
                ),
              ),
            ).paddingSymmetric(horizontal: 50),
            20.verticleSpace,
            Obx(
              () => ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, roomIndex) {
                  var room = roomList[roomIndex];

                  var adults = (room.persons ?? [])
                      .where((element) => element.type == 1)
                      .length;
                  var childs = (room.persons ?? [])
                      .where((element) => element.type == 0)
                      .length;

                  var adultTextController = TextEditingController(
                      text: '${adults == 0 ? '' : adults}');
                  var childTextController = TextEditingController(
                      text: '${childs == 0 ? '' : childs}');

                  var persons = room.persons ?? [];

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 2,
                            offset: Offset(0, 3),
                            spreadRadius: 2,
                          )
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(room.name!),
                        Row(
                          children: [
                            _getTypeInputItem("Enter Adult",
                                controller: adultTextController),
                            10.horizontalSpace,
                            _getTypeInputItem("Enter Child",
                                controller: childTextController),
                            OutlinedButton(
                                onPressed: () {
                                  if (adultTextController.text
                                          .trim()
                                          .isEmpty &&
                                      childTextController.text
                                          .trim()
                                          .isEmpty) {
                                    showMessage(
                                        'Please enter at-least 1 adult or child');
                                  } else {
                                    closeKeyboard(context);

                                    var adults = int.tryParse(
                                            adultTextController.text
                                                .trim()) ??
                                        0;
                                    var childs = int.tryParse(
                                            childTextController.text
                                                .trim()) ??
                                        0;
                                    room.persons = [
                                      ...List.generate(adults,
                                          (index) => Persons(type: 1)),
                                      ...List.generate(
                                          childs, (index) => Persons(type: 0))
                                    ];
                                    roomList.refresh();
                                  }
                                },
                                child: const Text('Add'))
                          ],
                        ),
                        if (persons.isNotEmpty) ...[
                          20.verticleSpace,
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (_, personIndex) {
                              var person = persons[personIndex];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                decoration: BoxDecoration(
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 2,
                                        offset: Offset(0, 3),
                                        spreadRadius: 2,
                                      )
                                    ],
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        person.type == 1 ? "Adult" : "Child"),
                                    Row(
                                      children: [
                                        _getTypeInputItem(
                                          "Enter Name",
                                          onChanged: (name) {
                                            person.name = name;
                                            roomList.refresh();
                                          },
                                          isNumber: false,
                                        ),
                                        10.horizontalSpace,
                                        _getTypeInputItem(
                                          "Enter Age",
                                          onChanged: (age) {
                                            person.age =
                                                int.tryParse(age) ?? 0;
                                            roomList.refresh();
                                          },
                                          maxLength: 2,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => 15.verticleSpace,
                            itemCount: persons.length,
                          )
                        ]
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => 20.verticleSpace,
                itemCount: roomList.length,
              ),
            ),
            20.verticleSpace,
            OutlinedButton(
              onPressed: () {
                if (checkValidations()) {
                  Get.to(Scaffold(
                    appBar: AppBar(
                      title: Text('Result'),
                      leading: BackButton(
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (_, roomIndex) {
                          var room = roomList[roomIndex];

                          var adults = (room.persons ?? [])
                              .where((element) => element.type == 1)
                              .length;
                          var childs = (room.persons ?? [])
                              .where((element) => element.type == 0)
                              .length;

                          var persons = room.persons ?? [];

                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 2,
                                    offset: Offset(0, 2),
                                    spreadRadius: 2,
                                  )
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Room : ${roomIndex + 1}'),
                                Text('Adult : $adults'),
                                Text('Child : $childs'),
                                15.verticleSpace,
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (_, personIndex) {
                                    var person = persons[personIndex];
                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 2,
                                              offset: Offset(0, 2),
                                              spreadRadius: 2,
                                            )
                                          ],
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('${personIndex + 1}'),
                                          Text('Name : ${person.name}'),
                                          Text('Age : ${person.age}'),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, __) => 15.verticleSpace,
                                  itemCount: persons.length,
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => 15.verticleSpace,
                        itemCount: roomList.length,
                      ),
                    ),
                  ));
                }
              },
              child: const Text('Submit'),
            ),
            20.verticleSpace,
          ],
        ),
      ),
    );
  }

  Widget _getTypeInputItem(
    String hint, {
    TextEditingController? controller,
    Function(String)? onChanged,
    bool isNumber = true,
    int? maxLength = 1,
  }) {
    return Expanded(
      child: TextField(
        onChanged: onChanged,
        maxLines: 1,
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          counter: const Offstage(),
        ),
        inputFormatters: isNumber
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                FilteringTextInputFormatter.digitsOnly,
              ]
            : [],
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLength: isNumber ? maxLength : null,
      ),
    );
  }

  void showMessage(String message) {
    Get.snackbar(
      'Alert!',
      message,
    );
  }

  void generateRooms() {
    roomList.clear();
    List.generate(
        int.parse(roomCount.value!),
        (index) => roomList.add(Room(
              name: 'Room ${index + 1}',
              persons: [],
            )));
  }

  bool checkValidations() {
    if (roomCount.value == null) {
      showMessage("Please select room");
      return false;
    } else if (roomList
            .firstWhereOrNull((element) => (element.persons ?? []).isEmpty) !=
        null) {
      showMessage("Please add persons into rooms");
      return false;
    } else {
      var person = roomList.firstWhereOrNull((element) =>
          element.persons!.firstWhereOrNull((element) =>
              ((element.name ?? '').isEmpty || element.age == 0)) !=
          null);
      if (person != null) {
        showMessage("Please enter name and age for all persons");
        return false;
      } else {
        var persons = <Persons>[];

        roomList.forEach((element) {
          persons.addAll(element.persons!.where((element) => element.type != null).toList());
        });

        var adultAge = persons.firstWhereOrNull((element) => ((element.type == 1) && element.age! <= 18));
        if(adultAge != null){
          showMessage("Adult age should be above 18 year");
          return false;
        }

        var childAge = persons.firstWhereOrNull((element) => ((element.type == 0) && element.age! > 18));
        if(childAge != null){
          showMessage("Child age should be below 18 year");
          return false;
        }

        return true;
      }
    }
  }

  void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rasxod/sql_helper.dart';

class OnPrice extends StatefulWidget {
  const OnPrice({super.key});

  @override
  State<OnPrice> createState() => _OnPriceState();
}

class _OnPriceState extends State<OnPrice> {
  final formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> journals1 = [];
  bool isLoading = true;

  Decimal totalSumOn = Decimal.zero;

  TextEditingController onPriceController = TextEditingController();
  TextEditingController date1Controller = TextEditingController();

  @override
  void dispose() {
    onPriceController.dispose();
    date1Controller.dispose();
    super.dispose();
  }

  refreshJournals1() async {
    isLoading = true;
    setState(() {});
    final data = await SQLHelper.getItems1();
    setState(() {
      journals1 = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshJournals1();
    print('....qo`shilgan ${journals1.length}');
  }

  Future<void> addItem1() async {
    await SQLHelper.createItem1(
      onPriceController.text.trim(),
      date1Controller.text.trim(),
    );
    await refreshJournals1();
  }

  Future<void> updateItem1(int id) async {
    await SQLHelper.updateItem1(
        id, onPriceController.text.trim(), date1Controller.text.trim());
    refreshJournals1();
  }

  void deleteItem1(int id) async {
    await SQLHelper.deleteItem1(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'O`chirildi!',
        ),
      ),
    );
    refreshJournals1();
  }

  void onForm(int? id) async {
    if (id != null) {
      final existingJournal1 =
          journals1.firstWhere((element) => element['id'] == id);
      onPriceController.text = existingJournal1['onPrice'];
      date1Controller.text = existingJournal1['date1'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: null,
                  keyboardType: TextInputType.number,
                  controller: onPriceController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    label: Row(
                      children: const [
                        Text(
                          'Kirim summa',
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '*',
                          style: TextStyle(color: Colors.red),
                        )
                      ],
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          8,
                        ),
                      ),
                    ),
                  ),
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomini kiriting';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: null,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  controller: date1Controller,
                  decoration: InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    label: Row(
                      children: const [
                        Text(
                          'Vaqt',
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '*',
                          style: TextStyle(color: Colors.red),
                        )
                      ],
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    hintText: 'Kun_Oy_Yil',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          8,
                        ),
                      ),
                    ),
                  ),
                  onTap: () async {
                    String tdata =
                        DateFormat('HH:mm:ss').format(DateTime.now());
                    DateTime? pickeddate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2100),
                    );
                    if (pickeddate != null) {
                      setState(() {
                        date1Controller.text =
                            DateFormat('dd-MM-yyyy $tdata').format(pickeddate);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vaqtni kiriting';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (id == null) {
                      await addItem1();
                    }
                    if (id != null) {
                      await updateItem1(id);
                    }
                    onPriceController.text = '';
                    date1Controller.text = '';
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Qo`shildi',
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Kataklar to`lishi shart',
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  id == null ? 'Qo`shish' : 'Yangilash',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // if(isLoading){
    //   return const Center(
    //       child:CircularProgressIndicator()
    //   );
    // }
    Decimal totalSumOn = journals1.fold<Decimal>(Decimal.zero, (sum1, journal) {
      Decimal price1 =
          Decimal.tryParse(journal['onPrice'].toString()) ?? Decimal.zero;
      return sum1 + price1;
    });
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                onForm(null);
              },
              child: const Icon(
                Icons.add,
                color: Colors.indigo,
              ),
            ),
          ),
        ],
        centerTitle: true,
        title: const Text('KIRIM'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: totalSumOn == Decimal.zero
              ? const SizedBox()
              : Column(
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Center(
                                child: Text(
                                  'Umumiy kirim',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              content: Container(
                                width: 100,
                                height: 150,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$totalSumOn so`m',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Ok'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Card(
                        child: SizedBox(
                          height: 70,
                          width: 400,
                          child: Column(
                            children: [
                              const Center(
                                child: Text(
                                  'Umumiy kirim',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '$totalSumOn so`m',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      body: journals1.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: journals1.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Ma`lumot'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Vaqti: ${journals1[index]['date1']}'),
                                      const SizedBox(height: 20),
                                      Text(
                                          'Narhi: ${journals1[index]['onPrice']}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Ok'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: ListTile(
                            leading: SizedBox(
                              width: 150,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(journals1[index]['date1']),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${journals1[index]['onPrice']} so`m',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      onForm(journals1[index]['id']);
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'O`chirishni xoxlaysizmi?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text("HA"),
                                                onPressed: () {
                                                  deleteItem1(
                                                      journals1[index]['id']);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("YO`Q"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          : const Center(
              child: Text(
                'Hozircha bo`sh',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
    );
  }
}

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rasxod/profit_page.dart';
import 'package:rasxod/sql_helper.dart';
import 'on_price.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> chiqimList = [];
  List<Map<String, dynamic>> kirimList = [];
  bool isLoading = true;

  Decimal totalSumOff = Decimal.zero;
  Decimal totalSumOn = Decimal.zero;

  TextEditingController nameController = TextEditingController();
  TextEditingController offPriceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController froController = TextEditingController();
  TextEditingController beforeController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    offPriceController.dispose();
    dateController.dispose();
    froController.dispose();
    beforeController.dispose();
    super.dispose();
  }

  loadData() async {
    isLoading = true;
    setState(() {});
    final data = await SQLHelper.getItems();
    final data1 = await SQLHelper.getItems1();
    kirimList = data1;

    setState(() {
      chiqimList = data;
      print('....qo`shilgan ${chiqimList.length}');
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> addItem() async {
    await SQLHelper.createItem(
      nameController.text.trim(),
      offPriceController.text.trim(),
      dateController.text.trim(),
      froController.text.trim(),
      beforeController.text.trim(),
    );
    await loadData();
  }

  Future<void> updateItem(int id) async {
    await SQLHelper.updateItem(
        id,
        nameController.text.trim(),
        offPriceController.text.trim(),
        dateController.text.trim(),
        froController.text.trim(),
        beforeController.text.trim());
    loadData();
  }

  void deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O`chirildi!',
          ),
        ),
      );
    }

    loadData();
  }

  void offForm(int? id) async {
    if (id != null) {
      final existingJournal =
      chiqimList.firstWhere((element) => element['id'] == id);
      nameController.text = existingJournal['name'];
      offPriceController.text = existingJournal['offPrice'];
      dateController.text = existingJournal['date'];
      froController.text = existingJournal['fro'];
      beforeController.text = existingJournal['before'];
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
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    label: Row(
                      children: [
                        Text(
                          'Nomi',
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
                    border: OutlineInputBorder(
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
                  keyboardType: TextInputType.number,
                  controller: offPriceController,
                  decoration: const InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    label: Row(
                      children: [
                        Text(
                          'Chiqim summa',
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          8,
                        ),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Summani kiriting';
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
                  controller: dateController,
                  decoration: const InputDecoration(
                    fillColor: Colors.black12,
                    filled: true,
                    label: Row(
                      children: [
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
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: 'Kun_Oy_Yil',
                    border: OutlineInputBorder(
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
                        dateController.text =
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
                      await addItem();
                    }
                    if (id != null) {
                      await updateItem(id);
                    }
                    nameController.text = '';
                    offPriceController.text = '';
                    dateController.text = '';
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
    // if (isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    Decimal totalSumOff = chiqimList.fold<Decimal>(Decimal.zero, (sum, journal) {
      Decimal price = Decimal.tryParse(journal['offPrice'].toString()) ?? Decimal.zero;
      return sum + price;
    });
    Decimal totalSumOn = kirimList.fold<Decimal>(Decimal.zero, (sum1, journal) {
      Decimal price1 = Decimal.tryParse(journal['onPrice'].toString()) ?? Decimal.zero;
      return sum1 + price1;
    }) - totalSumOff;
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              offForm(null);
            },
            child: const Icon(
              Icons.add,
              color: Colors.indigo,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfitPage()));
            },
            icon: const Icon(
              Icons.monetization_on_outlined,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnPrice(),
                ),
              );
              await loadData();
            },
            icon: const Icon(
              Icons.arrow_forward_outlined,
            ),
          ),
        ],
        centerTitle: true,
        title: const Text('CHIQIM'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: totalSumOff == Decimal.zero && totalSumOn == Decimal.zero
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
                            'Qolgan summa',
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
                            'Qolgan summa',
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
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Center(
                          child: Text(
                            'Umumiy chiqim',
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
                                  '$totalSumOff so`m',
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
                            'Umumiy chiqim',
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
                              '$totalSumOff so`m',
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
      body: chiqimList.isNotEmpty
          ? SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: chiqimList.length,
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
                                    'Vaqti: ${chiqimList[index]['date']}'),
                                const SizedBox(height: 8),
                                Text(
                                    'Nomi: ${chiqimList[index]['name']}'),
                                const SizedBox(height: 8),
                                Text(
                                    'Narhi: ${chiqimList[index]['offPrice']}'),
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
                            Text(chiqimList[index]['date']),
                            Expanded(
                              child: Text(
                                chiqimList[index]['name'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${chiqimList[index]['offPrice']} so`m',
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
                                offForm(chiqimList[index]['id']);
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
                                            deleteItem(
                                                chiqimList[index]['id']);
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

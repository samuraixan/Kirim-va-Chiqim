import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rasxod/sql_helper.dart';

class ProfitPage extends StatefulWidget {
  const ProfitPage({super.key});

  @override
  State<ProfitPage> createState() => _ProfitPageState();
}

class _ProfitPageState extends State<ProfitPage> {
  final formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> journals = [];
  Map<String, Decimal> totalPriceMap = {};

  Decimal common = Decimal.zero;

  TextEditingController fromController = TextEditingController();
  TextEditingController beforeController = TextEditingController();

  @override
  void dispose() {
    fromController.dispose();
    beforeController.dispose();
    super.dispose();
  }

  void refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      journals = data;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        centerTitle: true,
        title: const Text(
          'Hisoblagich',
          style: TextStyle(color: Colors.black),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          child: TextFormField(
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            controller: fromController,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              label: Row(
                                children: const [
                                  Text(
                                    'dan',
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
                              // String tdata = DateFormat('HH:mm:ss').format(DateTime.now());
                              DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2010),
                                lastDate: DateTime(2100),
                              );
                              if (pickeddate != null) {
                                setState(() {
                                  fromController.text = DateFormat('dd-MM-yyyy')
                                      .format(pickeddate);
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
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          child: TextFormField(
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            controller: beforeController,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              label: Row(
                                children: const [
                                  Text(
                                    'gacha',
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
                              // String tdata = DateFormat('HH:mm:ss').format(DateTime.now());
                              DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2010),
                                lastDate: DateTime(2100),
                              );
                              if (pickeddate != null) {
                                setState(() {
                                  beforeController.text =
                                      DateFormat('dd-MM-yyyy')
                                          .format(pickeddate);
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
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // background
                    foregroundColor: Colors.black, // foreground
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      List<Map<String, dynamic>> filteredJournals =
                          journals.where((journal) {
                        DateTime froDate = DateFormat('dd-MM-yyyy')
                            .parse(fromController.text.trim());
                        DateTime beforeDate = DateFormat('dd-MM-yyyy')
                            .parse(beforeController.text.trim());
                        DateTime journalDate =
                            DateFormat('dd-MM-yyyy').parse(journal['date']);

                        return journalDate.isAfter(
                                froDate.subtract(const Duration(days: 1))) &&
                            journalDate.isBefore(beforeDate);
                      }).toList();

                      Map<String, Decimal> totalPriceMap = {};
                      filteredJournals.forEach((journal) {
                        String name = journal['name'];
                        Decimal price =
                            Decimal.tryParse(journal['offPrice'].toString()) ??
                                Decimal.zero;
                        if (!totalPriceMap.containsKey(name)) {
                          totalPriceMap[name] = price;
                        } else {
                          totalPriceMap[name] = totalPriceMap[name]! + price;
                        }
                      });
                      Decimal totalSum = totalPriceMap.values
                          .fold<Decimal>(Decimal.zero, (sum, price) {
                        return sum + price;
                      });
                      setState(() {
                        journals = filteredJournals;
                        common = totalSum;
                        this.totalPriceMap = totalPriceMap;
                      });
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
                  child: const Text('Hisoblash'),
                ),
                common != Decimal.zero
                    ? InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Center(
                            child: Text(
                              'Tanlangan vaqt oralig`idagi rasxod',
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
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$common so`m',
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
                      height: 60,
                      width: 400,
                      child: Column(
                        children: [
                          const Center(
                            child: Text(
                              'Tanlangan vaqt oralig`idagi rasxod',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '$common so`m',
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
                )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: common != Decimal.zero
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: totalPriceMap.length,
                    itemBuilder: (context, index) {
                      String name = totalPriceMap.keys.toList()[index];
                      Decimal price = totalPriceMap.values.toList()[index];
                      return Card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text('Nomi: '),
                                Expanded(
                                  child: Text(
                                    name,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  'Narhi:',
                                ),
                                Expanded(
                                  child: Text(
                                    '${price.toString()} so`m',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}

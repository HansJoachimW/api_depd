part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Province> provinceData = [];

  bool isLoading = false;
  bool isLoadingCityOrigin = false;
  bool isLoadingCityDestination = false;

  Future<dynamic> getProvinces() async {
    await MasterDataService.getProvince().then((value) {
      setState(() {
        provinceData = value;
      });
    });
  }

  dynamic provinceIdOrigin;
  dynamic selectedprovinceOrigin;

  dynamic provinceIdDestination;
  dynamic selectedprovinceDestination;

  dynamic cityDataOrigin;
  dynamic cityIdOrigin;
  dynamic selectedCityOrigin;

  dynamic cityDataDestination;
  dynamic cityIdDestination;
  dynamic selectedCityDestination;

  Future<List<City>> getCities(var provId, var originORdestination) async {
    dynamic city;
    await MasterDataService.getCity(provId).then((value) {
      setState(() {
        city = value;
        if (originORdestination == 'origin') {
          isLoadingCityOrigin = false;
        } else {
          isLoadingCityDestination = false;
        }
      });
    });

    return city;
  }

  var courierSelection = 'jne';
  List<Costs> costData = [];

  Future<dynamic> getCost(
      var courier, var origin, var destination, var weight) async {
    ////
    dynamic costs;
    await MasterDataService.getCost(origin, destination, weight, courier)
        .then((value) {
      setState(() {
        costs = value;
      });
      isLoading = false;
    });

    return costs;
  }

  var weight = 0;

  @override
  void initState() {
    super.initState();
    getProvinces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Fee Calculator"),
        centerTitle: true,
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Stack(
          children: [
            Column(
              children: [
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: DropdownButtonFormField(
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'jne',
                                      child: Text('JNE'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'pos',
                                      child: Text('Pos'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'tiki',
                                      child: Text('Tiki'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      courierSelection = value as String;
                                    });
                                  },
                                  value: courierSelection,
                                  isDense: true,
                                  isExpanded: false,
                                  style: TextStyle(
                                      color: Colors.brown.shade300,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 30),
                              Flexible(
                                flex: 2,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Mass (in grams)',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      weight = int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Origin",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: provinceData.isEmpty
                                    ? UiLoading.loadingSmall()
                                    : DropdownButtonFormField(
                                        items: provinceData
                                            .map((Province province) {
                                          return DropdownMenuItem(
                                            value: province.provinceId,
                                            child:
                                                Text(province.province ?? ""),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            provinceIdOrigin = value;
                                            isLoadingCityOrigin = true;
                                            selectedCityOrigin = null;
                                            cityDataOrigin = getCities(
                                                provinceIdOrigin, 'origin');
                                          });
                                          cityIdOrigin = null;
                                        },
                                        value: provinceIdOrigin,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Select Province',
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: FutureBuilder<List<City>>(
                                  future: cityDataOrigin,
                                  builder: (context, snapshot) {
                                    if (isLoadingCityOrigin) {
                                      return UiLoading.loadingSmall();
                                    } else if (snapshot.hasData) {
                                      return DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityOrigin,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        hint: selectedCityOrigin == null
                                            ? const Text('Select city')
                                            : Text(selectedCityOrigin.cityName),
                                        items: snapshot.data!
                                            .map<DropdownMenuItem<City>>(
                                                (City value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child:
                                                Text(value.cityName.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedCityOrigin = newValue;
                                            cityIdOrigin =
                                                selectedCityOrigin.cityId;
                                          });
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Text("Data not found");
                                    }
                                    return AbsorbPointer(
                                      absorbing: true,
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityDestination,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        hint: const Text('Select city'),
                                        items: const [],
                                        onChanged: null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Destination",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: provinceData.isEmpty
                                    ? UiLoading.loadingSmall()
                                    : DropdownButtonFormField(
                                        items: provinceData
                                            .map((Province province) {
                                          return DropdownMenuItem(
                                            value: province.provinceId,
                                            child:
                                                Text(province.province ?? ""),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            provinceIdDestination = value;
                                            isLoadingCityDestination = true;
                                            selectedCityDestination = null;
                                            cityDataDestination = getCities(
                                                provinceIdDestination,
                                                'destination');
                                            cityIdDestination = null;
                                          });
                                        },
                                        value: provinceIdDestination,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Select Province',
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: FutureBuilder<List<City>>(
                                  future: cityDataDestination,
                                  builder: (context, snapshot) {
                                    if (isLoadingCityDestination) {
                                      return UiLoading.loadingSmall();
                                    } else if (snapshot.hasData) {
                                      return DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityDestination,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        hint: selectedCityDestination == null
                                            ? const Text('Select city')
                                            : Text(selectedCityDestination
                                                .cityName),
                                        items: snapshot.data!
                                            .map<DropdownMenuItem<City>>(
                                                (City value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child:
                                                Text(value.cityName.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selectedCityDestination = newValue;
                                            cityIdDestination =
                                                selectedCityDestination.cityId;
                                          });
                                        },
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Text("Data not found");
                                    }
                                    return AbsorbPointer(
                                      absorbing: true,
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: selectedCityDestination,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        iconSize: 30,
                                        elevation: 4,
                                        style: const TextStyle(
                                            color: Colors.black),
                                        hint: const Text('Select city'),
                                        items: const [],
                                        onChanged: null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (cityIdDestination == null ||
                                      cityIdOrigin == null ||
                                      weight < 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Fill in all fields to proceed.'),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    setState(() async {
                                      costData = await getCost(
                                        courierSelection,
                                        cityIdOrigin,
                                        cityIdDestination,
                                        weight,
                                      );
                                    });
                                  }
                                },
                                child: const Text('Calculate costs'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: costData.isEmpty || costData[0].cost.isEmpty
                          ? const Align(
                              alignment: Alignment.center,
                              child: Text("Data not found"),
                            )
                          : ListView.builder(
                              itemCount: costData.length,
                              itemBuilder: (context, index) {
                                return CardProvince(costData[index]);
                              })),
                ),
              ],
            ),
            isLoading == true ? UiLoading.loadingBlock() : Container()
          ],
        ),
      ),
    );
  }
}

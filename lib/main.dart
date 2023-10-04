import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_maps_webservice/places.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookVehiclePage(),
    );
  }
}

class BookVehiclePage extends StatefulWidget {
  @override
  _BookVehiclePageState createState() => _BookVehiclePageState();
}

class _BookVehiclePageState extends State<BookVehiclePage> {
  Color myColor = Color(0xFF29a4b6);
  Color myColor2 = Color(0xFF171749);

  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController telNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController promoController = TextEditingController();
   // Define a variable for the text
  String textInsideBox = "...";
  late DateTime startDate;
  late DateTime minDate;
  late DateTime maxDate;
  String searchFrom = "";
  String searchTo = "";
  bool showPersonalDetails = false;
  String promoCode = "PROMO.CODE";
  String distanceCost = "0";
  String distance = "0";
  bool validTime = true;
  String displayDate = "";
  bool isShopOpened = true;
  static const callCenterNumber = "0777400040";
  static const addedMinutes = 25;
  GoogleMapsPlaces _places =
  GoogleMapsPlaces(apiKey: "AIzaSyCDY5NB991GzLR9RMnH2usCDgpONPdq2Mo");
  List<Prediction> startSuggestions = [];
  List<Prediction> endSuggestions = [];

  @override
  void initState() {
    super.initState();
    startDate = minDate = DateTime.now().add(Duration(minutes: addedMinutes));
    setDisplayDate();
    maxDate = DateTime(DateTime.now().year, 12, 31);
  }

  void setDisplayDate() {
    displayDate = DateFormat("dd  | MMM | yyyy hh:mm a").format(startDate);
    startDate = minDate = DateTime.now().add(Duration(minutes: addedMinutes));
    maxDate = DateTime(DateTime.now().year, 12, 31);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [myColor, myColor2], // Set your gradient colors here
              ),
            ),
            child: Center(
              child: Container(
                width: double.infinity, // Makes the container take up the full width of the AppBar
                height: kToolbarHeight, // Sets the height to match the AppBar's height
                child: Image.asset('assets/images/app_head.png'),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Make the background of Scaffold transparent
          body: Stack(
          children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
               colors: [myColor, myColor2], // Set your gradient colors here
                ),
              ),
            ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 9.0),
                  TextField(
                    onChanged: (text) {
                      getPlaceSuggestions(text, true);
                    },
                    controller: startController,
                    decoration: InputDecoration(
                      labelText: "Current Location",
                      border: OutlineInputBorder(),
                      filled: true, // Set to true to fill the background
                      fillColor: Colors.white.withOpacity(0.7), // Set white with opacity// Add this line to specify the border
                    ),

                  ),
                  buildSuggestionsList(startSuggestions, true),
                  SizedBox(height: 9.0),
                  TextField(
                    onChanged: (text) {
                      getPlaceSuggestions(text, false);
                    },
                    controller: endController,
                    decoration: InputDecoration(
                      labelText: "Destination",
                      border: OutlineInputBorder(),
                      filled: true, // Set to true to fill the background
                        fillColor: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  buildSuggestionsList(endSuggestions, false),
                  SizedBox(height: 16.0),
                  Text("PICKUP DATE & TIME",
                      style: TextStyle(fontSize: 16.0,
                          color: Color(0xFFf1c40f)
                      ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    width: double.infinity, // Set width to take up full width
                    child: InkWell(
                      onTap: () {
                        openPicker();
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(2.0),
                          color: Colors.white.withOpacity(0.7),
                        ),
                        child: Text(
                          displayDate,
                          style: TextStyle(
                            fontSize: 16.0, // Adjust the font size as needed
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 9.0),
                  TextField(
                    controller: promoController,
                    decoration: InputDecoration(
                      labelText: "Promo Code (if any)",
                      border: OutlineInputBorder(),
                      filled: true, // Set to true to fill the background
                      fillColor: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0), // Add margin to the top
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            getEstimate();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFf1c40f)), // Change the color to your desired background color
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0), // Adjust the padding as needed
                            child: Text(
                              "Estimate >",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black // Adjust the font size as needed
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0), // Adjust the left margin as needed
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              textInsideBox,
                              style: TextStyle(
                                fontSize: 20.0,
                                  color: Color(0xFFf1c40f)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showPersonalDetails = !showPersonalDetails;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline,
                          color: Color(0xFFf1c40f),
                        ),
                        Text(
                          " ADD PICKUP INFORMATION",
                          style: TextStyle(fontSize: 18.0,
                          color: Color(0xFFf1c40f)),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showPersonalDetails,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 9.0),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                            filled: true, // Set to true to fill the background
                              fillColor: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 9.0),
                        TextField(
                          controller: telNoController,
                          decoration: InputDecoration(
                            labelText: "Phone Number",
                            border: OutlineInputBorder(),
                            filled: true, // Set to true to fill the background
                            fillColor: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 9.0),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            filled: true, // Set to true to fill the background
                            fillColor: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 18.0),
                        ElevatedButton(
                          onPressed: () {
                            reserveDriver();
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFFf1c40f)), // Change the color to your desired background color
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.0), // Adjust the padding as needed
                            child: Text(
                              "Reserve Your Driver",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.black // Adjust the font size as needed
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
                ],
        ),
        ),
    );
  }

  Widget buildSuggestionsList(
      List<Prediction> suggestions, bool isStartPoint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suggestions.map((prediction) {
        return ListTile(
          title: Text(prediction.description ?? ""),
          onTap: () {
            setState(() {
              if (isStartPoint) {
                searchFrom = prediction.description ?? "";
                startSuggestions.clear();
                startController.text = searchFrom;
              } else {
                searchTo = prediction.description ?? "";
                endSuggestions.clear();
                endController.text = searchTo;
              }
            });
          },
        );
      }).toList(),
    );
  }

  void openPicker() {
    picker.DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: minDate,
      maxTime: maxDate,
      onConfirm: (date) {
        setState(() {
          startDate = date;
          setDisplayDate();
        });
      },
    );
  }

  void getEstimate() async {
    if (isEstimatePossible()) {
      showSpinner(true, true); // Show loading dialog with progress indicator

      try {
        final origins = Uri.encodeQueryComponent(searchFrom);
        final destinations = Uri.encodeQueryComponent(searchTo);
        final distanceUrl =
            "https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origins&destinations=$destinations&departure_time=now&key=AIzaSyCDY5NB991GzLR9RMnH2usCDgpONPdq2Mo";

        final response = await http.get(Uri.parse(distanceUrl));

        if (response.statusCode == 200) {
          final Map<String, dynamic> distanceInfo = json.decode(response.body);

          if (distanceInfo != null &&
              distanceInfo['rows'] != null &&
              distanceInfo['rows'][0]['elements'] != null) {
            final String distanceText =
            distanceInfo['rows'][0]['elements'][0]['distance']['text'];

            final costUrl =
                "http://youdrinkwedrive.lk/costcalc-api/?estimated_distance=$distanceText&client_promo_code=${promoController.text}";

            final costResponse = await http.get(Uri.parse(costUrl));

            if (costResponse.statusCode == 200) {
              final Map<String, dynamic> costInfo =
              json.decode(costResponse.body);
              final int finalCost = costInfo['final_cost'];

              setState(() {
                distance = distanceText;
                distanceCost = finalCost.toString(); // Convert to string
                textInsideBox = "$distanceText / Rs.$finalCost";
              });


            } else {
              showToast("Failed to calculate cost");
            }
          } else {
            showToast("Failed to fetch distance information");
          }
        } else {
          showToast("Failed to fetch distance information");
        }
      } catch (e) {
        showToast("Error occurred while calculating estimate");
      } finally {
        showSpinner(false, true); // Hide loading dialog with progress indicator
      }
    }
  }

  void reserveDriver() async {
    if (isReservable()) {
      showSpinner(true, true); // Show loading dialog with progress indicator

      try {
        final baseUrl = "http://youdrinkwedrive.lk/recordtrip-api";
        final url = Uri.parse("$baseUrl?client_name=${nameController.text}&client_phone_no=${telNoController.text}&client_email=${emailController.text}&pickup_location=$searchFrom&destination=$searchTo&pickup_date=${DateFormat('yyyy-MM-dd').format(startDate)}&pickup_time=${DateFormat('HH:mm:ss').format(startDate)}&estimated_cost=$distanceCost&estimated_distance=$distance&promoCode=${promoController.text}&source=app_android");

        final response = await http.get(
          url,
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if(data['result'] == 1){
            showToast("Something went wrong while saving the trip.");
          }else if(data['result'] == 0 ){
            showToast("Trip Saved Successfully.");
          }else{
            showToast("Failed to reserve driver");
          }
          showMessage(data['result']);
        } else {
          showToast("Failed to reserve driver");
        }
      } catch (e) {
        showToast("Error occurred while reserving driver");
      } finally {
        showSpinner(false, true); // Hide loading dialog with progress indicator
      }
    }
  }

  bool isEstimatePossible() {
    return true; // Implement your validation logic for estimate here
  }

  bool isReservable() {
    return true; // Implement your validation logic for reservation here
  }

  void showMessage(int result) {
    String message = "";
    switch (result) {
      case 0:
        message = "Thank you for submitting your information.";
        startController.clear();
        endController.clear();
        promoController.clear();
        nameController.clear();
        telNoController.clear();
        emailController.clear();
        break;
      case 1:
        message =
        "Sorry, there has been an issue with our system. Please try again later.";
        break;
      case 2:
        message = "Please fill all required fields.";
        break;
      case 3:
        message = "Sorry, our drivers are not available at the moment.";
        break;
    }
    showToast(message);
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  }

  Future<void> getPlaceSuggestions(String input, bool isStartPoint) async {
    if (input.isNotEmpty) {
      PlacesAutocompleteResponse response = await _places.autocomplete(
        input,
        components: [Component(Component.country, "LK")],
      );

      if (response.isOkay) {
        List<Prediction> predictions = response.predictions;
        if (isStartPoint) {
          setState(() {
            startSuggestions = predictions;
          });
        } else {
          setState(() {
            endSuggestions = predictions;
          });
        }
      } else {
        showToast("Failed to fetch place suggestions");
      }
    }
  }

  void showSpinner(bool show, bool modal) {
    // Implement your loading dialog (spinner) here
    // You can use a package like flutter_spinkit or create your custom widget
    // 'show' is a flag to show or hide the spinner
    // 'modal' is a flag to decide whether the spinner should block user interaction or not
    // You can display the spinner as a dialog or overlay as per your preference.
  }
}

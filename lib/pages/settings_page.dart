import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color selectedColor = Colors.blue;
  String selectedMarker = 'X';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Color del Cartón:', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                colorOption(Colors.blue),
                colorOption(Colors.red),
                colorOption(Colors.green),
                colorOption(Colors.yellow),
              ],
            ),
            SizedBox(height: 20),
            Text('Marcador Favorito:', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                markerOption('X'),
                markerOption('O'),
                markerOption('✔'),
                markerOption('✖'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget colorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: EdgeInsets.all(4.0),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget markerOption(String marker) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMarker = marker;
        });
      },
      child: Container(
        margin: EdgeInsets.all(4.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedMarker == marker ? Colors.grey[300] : Colors.white,
          border: Border.all(
            color: selectedMarker == marker ? Colors.black : Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(marker, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

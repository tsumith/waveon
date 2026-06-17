import 'dart:convert';

class DataPacket {
  final String action;
  final Map<String, dynamic>? payload;
  DataPacket({required this.action, this.payload});

  String toJsonString() {
    return jsonEncode({'action': action, 'payload': payload});
  }

  factory DataPacket.fromJsonString(String jsonStr) {
    final Map<String, dynamic> data = jsonDecode(jsonStr);
    return DataPacket(action: data['action'], payload: data['payload']);
  }
}

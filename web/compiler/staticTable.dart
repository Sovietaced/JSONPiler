library staticTable;

class StaticTable {
  
  static String TYPE_INT = "int";
  static String TYPE_STRING = "string";
  static String TYPE_BOOLEAN = "boolean";
  static final int ADDRESS_LENGTH = 4;

  List<StaticTableRow> rows;

  StaticTable() {
    this.rows = new List<StaticTableRow>();
  }

  String addRow(String name, String type,  num scope) {
    String location = "T" + this.rows.length.toString() + "XX";
    this.rows.add(new StaticTableRow(location, name, type, scope));
    return location;
  }

  StaticTableRow getRow(String name, num scope) {
    for (StaticTableRow row in this.rows) {
      if (row.name == name && row.scope <= scope) {
        return row;
      }
    }
    return null;
  }

  bool rowExists(String name, num scope) {
    for (StaticTableRow row in this.rows) {
      if (row.name == name && row.scope <= scope) {
        return true;
      }
    }
    return false;
  }

  dump() {
    for (StaticTableRow row in this.rows) {
      print(row);
    }
  }
}

class StaticTableRow {
  String location;
  String name;
  String address = "";
  num scope;
  String type;

  StaticTableRow(this.location, this.name, this.type, this.scope);

  String toString() {
    return "Row name=${this.name} location=${this.location} address=${this.address} type=${this.type} scope=${this.scope}";
  }
  
  void setAddress(String address) {
    this.address = address;
  }
}

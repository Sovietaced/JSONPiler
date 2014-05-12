library staticTable;

class StaticTable {
  
  static final int ADDRESS_LENGTH = 4;

  List<StaticTableRow> rows;

  StaticTable() {
    this.rows = new List<StaticTableRow>();
  }

  String addRow(String name, num scope) {
    String location = "T" + this.rows.length.toString() + "XX";
    this.rows.add(new StaticTableRow(location, name, scope));
    return location;
  }

  StaticTableRow getRow(String name) {
    for (StaticTableRow row in this.rows) {
      if (row.name == name) {
        return row;
      }
    }
    return null;
  }

  bool rowExists(String name) {
    for (StaticTableRow row in this.rows) {
      if (row.name == name) {
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

  StaticTableRow(this.location, this.name, this.scope);

  String toString() {
    return "Row name=${this.name} location=${this.location} address=${this.address} scope=${this.scope}";
  }
  
  void setAddress(String address) {
    this.address = address;
  }
}

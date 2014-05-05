library staticTable;

class StaticTable {

  List<StaticTableRow> rows;

  StaticTable() {
    this.rows = new List<StaticTableRow>();
  }

  String addRow(String name, num address) {
    String location = "T" + this.rows.length.toString() + "XX";
    this.rows.add(new StaticTableRow(location, name, address));
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
  num address;

  StaticTableRow(this.location, this.name, this.address);

  String toString() {
    return "Row name=${this.name} location=${this.location} address=${this.address}";
  }
}

library staticTable;

class StaticTable{
 
  List<Row> rows; 
  
  StaticTable() {
    this.rows = new List<Row>();
  }
  
  String addRow(String name, num address) {
    String location = "T" + this.rows.length.toString() + "XX";
    this.rows.add(new Row(location, name, address));
    return location;
  }
}

class Row {
    String location;
    String name;
    num address;
    
    Row(this.location, this.name, this.address);
  }
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
  
  dump() {
    for(Row row in this.rows) {
      print(row);
    }
  }
}

class Row {
    String location;
    String name;
    num address;
    
    Row(this.location, this.name, this.address);
    
    String toString() {
      return "Row name=${this.name} location=${this.location} address=${this.address}";  
    }
  }
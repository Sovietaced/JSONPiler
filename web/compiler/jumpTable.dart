library jumpTable;

class JumpTable{
 
  List<Row> rows; 
  
  JumpTable() {
    this.rows = new List<Row>();
  }
  
  void addRow(String location, num distance) {
    this.rows.add(new Row(location, distance));
  }
}

class Row {
    String location;
    num distance;
    
    Row(this.location, this.distance);
  }
library jumpTable;

class JumpTable{
 
  List<JumpTableRow> rows; 
  
  JumpTable() {
    this.rows = new List<JumpTableRow>();
  }
  
  String addRow() {
    String location = "J" + this.rows.length.toString();
    this.rows.add(new JumpTableRow(location));
    return location;
  }
}

class JumpTableRow {
    String location;
    num distance;
    
    JumpTableRow(this.location);
  }
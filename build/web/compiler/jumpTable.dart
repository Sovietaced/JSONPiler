library jumpTable;

class JumpTable {

  List<JumpTableRow> rows;

  JumpTable() {
    this.rows = new List<JumpTableRow>();
  }

  String addRow() {
    String location = "J" + this.rows.length.toString();
    this.rows.add(new JumpTableRow(location));
    return location;
  }
  
  /**
   * Set the distance of the jump table row when backtracking
   */
  void setDistance(String location, num distance) {
    JumpTableRow row = getRow(location);
    row.distance = distance;
  }

  JumpTableRow getRow(String location) {
    for (JumpTableRow row in this.rows) {
      if (row.location == location) {
        return row;
      }
    }
    return null;
  }

  bool rowExists(String location) {
    for (JumpTableRow row in this.rows) {
      if (row.location == location) {
        return true;
      }
    }
    return false;
  }
}

class JumpTableRow {
  String location;
  num distance;

  JumpTableRow(this.location);
}

library ConversionUtil;

class ConversionUtil {
  /**
     * Generates a littleEndian version of the string by adding leading zeroes
     */
  static String toLittleEndian(String value, int desiredLength) {
    assert(value.length <= 2); // to remind me to enhance this if needed
    value = makeEven(value);

    while (value.length < desiredLength) {
      value = value + "00";
    }

    print("NEW EVEN VALUE BRO " + value.toUpperCase());
    return value.toUpperCase();
  }

  static String makeEven(String value) {
    // Make string even
    if (value.length % 2 != 0) {
      if (value.length == 1) {
        value = "0" + value;
      } else {
        value = value.substring(0, value.length - 2) + "0" + value[value.length - 1];
      }
    }
    return value;
  }

  static String numToHex(int value) {
    String number = value.toRadixString(16).toUpperCase();
    return makeEven(number);
  }

  /**
     * Turns a plain old string into a null terminated hex string ready for code.
     * Iterates over the character codes and encodes the integer values into hex.
     */
  static String stringToHex(String value) {
    String hexString = "";
    // Strip quotes
    value = value.replaceAll("\"", "");

    for (int i in value.codeUnits) {
      hexString = hexString + numToHex(i);
    }

    // Null terminate
    hexString = hexString + "00";

    return hexString;
  }

  static String booleanToHex(String value) {
    if (value == "true") {
      return "02";
    } else {
      return "01";
    }
  }

  static String determineType(String value) {

    // Check if int
    try {
      num.parse(value);
      return "int";
      // If an exception is thrown the value is either a string or a boolean
    } on FormatException {
      if (value == "true" || value == "false") {
        return "boolean";
      } else {
        return "string";
      }
    }
  }

}

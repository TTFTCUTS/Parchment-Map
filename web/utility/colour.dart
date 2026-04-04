class Colour {
  static Colour DEFAULT = new Colour(127,127,127);
  static Colour WHITE = new Colour(255,255,255);

  int red;
  int green;
  int blue;

  Colour(int this.red, int this.green, int this.blue);

  String toString() {
    return "rgb($red, $green, $blue)";
  }

  operator * (Object other) {
    if (other is num) {
      return new Colour((red*other).clamp(0, 255).floor(), (green*other).clamp(0, 255).floor(), (blue*other).clamp(0, 255).floor());
    }
    else if (other is Colour) {
      return new Colour(
        (((red/255) * (other.red/255)).clamp(0, 1) * 255).round(),
        (((green/255) * (other.green/255)).clamp(0, 1) * 255).round(),
        (((blue/255) * (other.blue/255)).clamp(0, 1) * 255).round(),
      );
    }
  }

  operator + (Object other) {
    if (other is Colour) {
      return new Colour (other.red + red, other.green + green, other.blue + blue);
    }
  }

  int get to32Bit => 0xFF << 24 | blue << 16 | green << 8 | red;
}
import 'package:flutter/widgets.dart';

abstract final class AppRadii {
  static const Radius xs = Radius.circular(6);
  static const Radius sm = Radius.circular(10);
  static const Radius md = Radius.circular(14);
  static const Radius lg = Radius.circular(18);
  static const Radius xl = Radius.circular(24);
  static const Radius pill = Radius.circular(999);

  static const BorderRadius brSm = BorderRadius.all(sm);
  static const BorderRadius brMd = BorderRadius.all(md);
  static const BorderRadius brLg = BorderRadius.all(lg);
  static const BorderRadius brXl = BorderRadius.all(xl);
  static const BorderRadius brPill = BorderRadius.all(pill);
}

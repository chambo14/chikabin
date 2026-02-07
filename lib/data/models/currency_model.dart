enum Currency {
  fcfa('FCFA', 'Franc CFA', 'fr_FR', 1),
  usd('USD', 'Dollar américain', 'en_US', 655.957),
  eur('EUR', 'Euro', 'fr_FR', 655.957);

  final String symbol;
  final String name;
  final String locale;
  final double rateToFCFA;

  const Currency(this.symbol, this.name, this.locale, this.rateToFCFA);

  String format(double amount) {
    final convertedAmount = this == Currency.fcfa
        ? amount
        : amount / rateToFCFA;

    return '${convertedAmount.toStringAsFixed(this == Currency.fcfa ? 0 : 2)} $symbol';
  }
}
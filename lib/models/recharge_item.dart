class RechargeItem {
  final String id;
  final double price;
  final int coins;
  final String displayPrice;
  final String displayCoins;
  final bool isPopular;
  final bool isBestValue;

  const RechargeItem({
    required this.id,
    required this.price,
    required this.coins,
    required this.displayPrice,
    required this.displayCoins,
    this.isPopular = false,
    this.isBestValue = false,
  });
}

const List<RechargeItem> rechargeItems = [
  RechargeItem(
    id: 'tanyu_8',
    price: 8.0,
    coins: 650,
    displayPrice: '¥8',
    displayCoins: '650',
  ),
  RechargeItem(
    id: 'tanyu_12',
    price: 12.0,
    coins: 980,
    displayPrice: '¥12',
    displayCoins: '980',
    isPopular: true,
  ),
  RechargeItem(
    id: 'tanyu_28',
    price: 28.0,
    coins: 2380,
    displayPrice: '¥28',
    displayCoins: '2380',
  ),
  RechargeItem(
    id: 'tanyu_68',
    price: 68.0,
    coins: 5920,
    displayPrice: '¥68',
    displayCoins: '5920',
  ),
  RechargeItem(
    id: 'tanyu_98',
    price: 98.0,
    coins: 8820,
    displayPrice: '¥98',
    displayCoins: '8820',
    isBestValue: true,
  ),
  RechargeItem(
    id: 'tanyu_198',
    price: 198.0,
    coins: 18220,
    displayPrice: '¥198',
    displayCoins: '18220',
  ),
  RechargeItem(
    id: 'tanyu_298',
    price: 298.0,
    coins: 28310,
    displayPrice: '¥298',
    displayCoins: '28310',
  ),
  RechargeItem(
    id: 'tanyu_698',
    price: 698.0,
    coins: 68400,
    displayPrice: '¥698',
    displayCoins: '68400',
  ),
  RechargeItem(
    id: 'tanyu_998',
    price: 998.0,
    coins: 99800,
    displayPrice: '¥998',
    displayCoins: '99800',
  ),
];
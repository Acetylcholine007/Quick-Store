class ProductData {
  int quantity;
  double sellingPrice;
  double originalPrice;

  ProductData(this.quantity, this.sellingPrice, this.originalPrice);

  double get totalSellingPrice => sellingPrice * quantity;

  double get totalOriginalPrice => originalPrice * quantity;

  double get totalProfit => totalSellingPrice - totalOriginalPrice;

  ProductData combine (ProductData item) {
    this.quantity += item.quantity;
    this.sellingPrice += item.sellingPrice;
    this.originalPrice += item.originalPrice;
    return this;
  }
}
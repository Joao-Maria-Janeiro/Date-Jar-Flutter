class Category {
  int id;
  String name, type;

  Category(this.id, this.name, this.type);

  factory Category.fromJson(Map<String, dynamic> product) =>
      Category(product['id'], product['name'], product['type']);
}

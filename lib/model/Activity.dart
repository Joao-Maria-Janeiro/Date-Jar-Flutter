class Activity {
  int id, categoryId;
  String name;

  Activity(this.id, this.name, this.categoryId);

  factory Activity.fromJson(Map<String, dynamic> product) =>
      Activity(product['id'], product['name'], product['category_id']);
}

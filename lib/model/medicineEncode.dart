class MedicineEncode{

  int? _id;
  int? _price;
  int? _qty;


  int? get id => _id;

  set id(int? id) {
    _id = id;
  }

  int? get price => _price;

  set price(int? price) {
    _price = price;
  }

  int? get qty => _qty;

  set qty(int? qty) {
    _qty = qty;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['price'] = this.price;
    data['qty'] = this.qty;
    return data;
  }


 }
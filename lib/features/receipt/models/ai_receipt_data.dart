class AIReceiptData {
  final MerchantDetails merchantDetails;
  final TransactionDetails transactionDetails;
  final List<ReceiptItem> items;
  final AdditionalInfo additionalInfo;

  const AIReceiptData({
    required this.merchantDetails,
    required this.transactionDetails,
    required this.items,
    required this.additionalInfo,
  });

  factory AIReceiptData.fromJson(Map<String, dynamic> json) {
    return AIReceiptData(
      merchantDetails: MerchantDetails.fromJson(json['merchant_details'] ?? {}),
      transactionDetails: TransactionDetails.fromJson(
        json['transaction_details'] ?? {},
      ),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ReceiptItem.fromJson(item))
              .toList() ??
          [],
      additionalInfo: AdditionalInfo.fromJson(json['additional_info'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_details': merchantDetails.toJson(),
      'transaction_details': transactionDetails.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'additional_info': additionalInfo.toJson(),
    };
  }
}

class MerchantDetails {
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final String website;

  const MerchantDetails({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.website,
  });

  factory MerchantDetails.fromJson(Map<String, dynamic> json) {
    return MerchantDetails(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'website': website,
    };
  }
}

class TransactionDetails {
  final String transactionId;
  final String date;
  final String time;
  final String paymentMethod;
  final String paymentProvider;
  final String cardOrAccountLast4;
  final String currency;
  final String subtotal;
  final String tax;
  final String discount;
  final String totalAmount;

  const TransactionDetails({
    required this.transactionId,
    required this.date,
    required this.time,
    required this.paymentMethod,
    required this.paymentProvider,
    required this.cardOrAccountLast4,
    required this.currency,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.totalAmount,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactionId: json['transaction_id'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      paymentProvider: json['payment_provider'] ?? '',
      cardOrAccountLast4: json['card_or_account_last4'] ?? '',
      currency: json['currency'] ?? '',
      subtotal: json['subtotal'] ?? '',
      tax: json['tax'] ?? '',
      discount: json['discount'] ?? '',
      totalAmount: json['total_amount'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'date': date,
      'time': time,
      'payment_method': paymentMethod,
      'payment_provider': paymentProvider,
      'card_or_account_last4': cardOrAccountLast4,
      'currency': currency,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total_amount': totalAmount,
    };
  }
}

class ReceiptItem {
  final String itemName;
  final String quantity;
  final String unitPrice;
  final String totalPrice;
  final String category;

  const ReceiptItem({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.category,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? '',
      unitPrice: json['unit_price'] ?? '',
      totalPrice: json['total_price'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'category': category,
    };
  }
}

class AdditionalInfo {
  final String notes;
  final String terminalId;
  final String invoiceNumber;
  final String referenceNumber;
  final String receiptType;
  final String country;
  final String language;

  const AdditionalInfo({
    required this.notes,
    required this.terminalId,
    required this.invoiceNumber,
    required this.referenceNumber,
    required this.receiptType,
    required this.country,
    required this.language,
  });

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalInfo(
      notes: json['notes'] ?? '',
      terminalId: json['terminal_id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      referenceNumber: json['reference_number'] ?? '',
      receiptType: json['receipt_type'] ?? '',
      country: json['country'] ?? '',
      language: json['language'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notes': notes,
      'terminal_id': terminalId,
      'invoice_number': invoiceNumber,
      'reference_number': referenceNumber,
      'receipt_type': receiptType,
      'country': country,
      'language': language,
    };
  }
}

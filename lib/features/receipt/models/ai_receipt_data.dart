/// Simplified AI receipt data for transaction form
class AIReceiptData {
  final double? amount;
  final String? categorySuggestion;
  final DateTime? dateTime;
  final String description;

  const AIReceiptData({
    this.amount,
    this.categorySuggestion,
    this.dateTime,
    required this.description,
  });

  factory AIReceiptData.fromJson(Map<String, dynamic> json) {
    // Parse amount
    double? amount;
    final amountStr = json['amount'] as String? ?? '';
    if (amountStr.isNotEmpty) {
      final clean = amountStr.replaceAll(RegExp('[^0-9.,-]'), '');
      amount = double.tryParse(clean.replaceAll(',', ''));
    }

    // Parse datetime
    DateTime? dateTime;
    final dateStr = json['date'] as String? ?? '';
    final timeStr = json['time'] as String? ?? '';

    if (dateStr.isNotEmpty) {
      try {
        final parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        if (timeStr.isNotEmpty) {
          final timeParts = timeStr.split(':');
          if (timeParts.length >= 2) {
            final hour = int.tryParse(timeParts[0]) ?? 0;
            final minute = int.tryParse(timeParts[1]) ?? 0;
            dateTime = DateTime(
              parsedDate.year,
              parsedDate.month,
              parsedDate.day,
              hour,
              minute,
            );
          } else {
            dateTime = parsedDate;
          }
        } else {
          dateTime = parsedDate;
        }
      } catch (_) {
        dateTime = null;
      }
    }

    // Build description from merchant name
    final merchantName = json['merchant_name'] as String? ?? '';
    final description = merchantName.isNotEmpty
        ? 'Receipt - $merchantName'
        : 'Receipt transaction';

    return AIReceiptData(
      amount: amount,
      categorySuggestion: json['category_suggestion'] as String?,
      dateTime: dateTime,
      description: description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount?.toString() ?? '',
      'category_suggestion': categorySuggestion ?? '',
      'date': dateTime?.toIso8601String() ?? '',
      'merchant_name': description.replaceFirst('Receipt - ', ''),
    };
  }
}

// Keep old models for backward compatibility if needed elsewhere
class AIReceiptDataDetailed {
  final MerchantDetails merchantDetails;
  final TransactionDetails transactionDetails;
  final List<ReceiptItem> items;
  final AdditionalInfo additionalInfo;

  const AIReceiptDataDetailed({
    required this.merchantDetails,
    required this.transactionDetails,
    required this.items,
    required this.additionalInfo,
  });

  factory AIReceiptDataDetailed.fromJson(Map<String, dynamic> json) {
    return AIReceiptDataDetailed(
      merchantDetails: MerchantDetails.fromJson(
        (json['merchant_details'] ?? <String, dynamic>{})
            as Map<String, dynamic>,
      ),
      transactionDetails: TransactionDetails.fromJson(
        (json['transaction_details'] ?? <String, dynamic>{})
            as Map<String, dynamic>,
      ),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) => ReceiptItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      additionalInfo: AdditionalInfo.fromJson(
        (json['additional_info'] ?? <String, dynamic>{})
            as Map<String, dynamic>,
      ),
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
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
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
      transactionId: json['transaction_id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentProvider: json['payment_provider'] as String? ?? '',
      cardOrAccountLast4: json['card_or_account_last4'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      subtotal: json['subtotal'] as String? ?? '',
      tax: json['tax'] as String? ?? '',
      discount: json['discount'] as String? ?? '',
      totalAmount: json['total_amount'] as String? ?? '',
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
      itemName: json['item_name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      unitPrice: json['unit_price'] as String? ?? '',
      totalPrice: json['total_price'] as String? ?? '',
      category: json['category'] as String? ?? '',
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
      notes: json['notes'] as String? ?? '',
      terminalId: json['terminal_id'] as String? ?? '',
      invoiceNumber: json['invoice_number'] as String? ?? '',
      referenceNumber: json['reference_number'] as String? ?? '',
      receiptType: json['receipt_type'] as String? ?? '',
      country: json['country'] as String? ?? '',
      language: json['language'] as String? ?? '',
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

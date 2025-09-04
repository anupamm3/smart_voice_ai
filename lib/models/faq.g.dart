// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FAQAdapter extends TypeAdapter<FAQ> {
  @override
  final int typeId = 3;

  @override
  FAQ read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FAQ(
      id: fields[0] as String,
      question: fields[1] as String,
      answer: fields[2] as String,
      keywords: (fields[3] as List).cast<String>(),
      category: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FAQ obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.answer)
      ..writeByte(3)
      ..write(obj.keywords)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FAQAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

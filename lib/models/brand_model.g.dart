// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BrandModelAdapter extends TypeAdapter<BrandModel> {
  @override
  final int typeId = 0;

  @override
  BrandModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BrandModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      targetAudience: fields[3] as String?,
      category: fields[4] as String?,
      imagePath: fields[5] as String,
      productions: fields[6] as int,
      tagline: fields[9] as String?,
      websiteUrl: fields[10] as String?,
      brandVoice: fields[11] as String?,
      colorPrimary: fields[12] as String?,
      colorSecondary: fields[13] as String?,
      colorAccent: fields[14] as String?,
      instagram: fields[15] as String?,
      tiktok: fields[16] as String?,
      facebook: fields[17] as String?,
      twitter: fields[18] as String?,
      youtube: fields[19] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BrandModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.targetAudience)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.productions)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.tagline)
      ..writeByte(10)
      ..write(obj.websiteUrl)
      ..writeByte(11)
      ..write(obj.brandVoice)
      ..writeByte(12)
      ..write(obj.colorPrimary)
      ..writeByte(13)
      ..write(obj.colorSecondary)
      ..writeByte(14)
      ..write(obj.colorAccent)
      ..writeByte(15)
      ..write(obj.instagram)
      ..writeByte(16)
      ..write(obj.tiktok)
      ..writeByte(17)
      ..write(obj.facebook)
      ..writeByte(18)
      ..write(obj.twitter)
      ..writeByte(19)
      ..write(obj.youtube);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

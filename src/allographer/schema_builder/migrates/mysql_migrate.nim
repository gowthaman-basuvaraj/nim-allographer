import strformat, strutils, json
import
  ../table,
  ../column
import ../generators/mysql_generators


proc migrate*(this:Table):string =
  var columnString = ""
  var foreignString = ""
  for i, column in this.columns:
    if i > 0: columnString.add(", ")

    case column.typ:
      # int ===================================================================
      of rdbIncrements:
        columnString.add(
          serialGenerator(column.name)
        )
      of rdbInteger:
        columnString.add(
          intGenerator(
            column.name,
            column.isNullable,
            column.isDefault,
            column.defaultInt,
            column.isUnsigned
          )
        )
      of rdbSmallInteger:
        columnString.add(
          smallIntGenerator(
            column.name,
            column.isNullable,
            column.isDefault,
            column.defaultInt,
            column.isUnsigned
          )
        )
      of rdbMediumInteger:
        columnString.add(
          mediumIntGenerator(
            column.name,
            column.isNullable,
            column.isDefault,
            column.defaultInt,
            column.isUnsigned
          )
        )
      of rdbBigInteger:
        columnString.add(
          bigIntGenerator(
            column.name,
            column.isNullable,
            column.isDefault,
            column.defaultInt,
            column.isUnsigned
          )
        )
      # # float =================================================================
      of rdbDecimal:
        columnString.add(
          decimalGenerator(
            column.name,
            parseInt($column.info["maximum"]),
            parseInt($column.info["digit"]),
            column.isNullable,
            column.isDefault,
            column.defaultFloat
          )
        )
      of rdbDouble:
        columnString.add(
          doubleGenerator(
            column.name,
            parseInt($column.info["maximum"]),
            parseInt($column.info["digit"]),
            column.isNullable,
            column.isDefault,
            column.defaultFloat
          )
        )
      of rdbFloat:
        columnString.add(
          floatGenerator(
            column.name,
            column.isNullable,
            column.isDefault,
            column.defaultFloat,
            column.isUnsigned
          )
        )
      # # char ==================================================================
      of rdbChar:
        columnString.add(
          charGenerator(
            column.name,
            parseInt($column.info["maxLength"]),
            column.isNullable,
            column.isDefault,
            column.defaultString
          )
        )
      of rdbString:
        columnString.add(
          stringGenerator(
            column.name,
            parseInt($column.info["maxLength"]),
            column.isNullable,
            column.isDefault,
            column.defaultString
          )
        )
      of rdbText:
        columnString.add(
          textGenerator(
            column.name,
            column.isNullable
          )
        )
      of rdbMediumText:
        columnString.add(
          mediumTextGenerator(
            column.name,
            column.isNullable
          )
        )
      of rdbLongText:
        columnString.add(
          longTextGenerator(
            column.name,
            column.isNullable
          )
        )
      # # date ==================================================================
      of rdbDate:
        columnString.add(
          dateGenerator(column.name, column.isNullable, column.isDefault)
        )
      of rdbDatetime:
        columnString.add(
          datetimeGenerator(column.name, column.isNullable, column.isDefault)
        )
      of rdbTime:
        columnString.add(
          timeGenerator(column.name, column.isNullable, column.isDefault)
        )
      of rdbTimestamp:
        columnString.add(
          timestampGenerator(
            column.name,
            column.isNullable,
            column.isDefault
          )
        )
      of rdbTimestamps:
        columnString.add(
          timestampsGenerator()
        )
      of rdbSoftDelete:
        columnString.add(
          softDeleteGenetator()
        )
      # # others ================================================================
      of rdbBinary:
        columnString.add(
          blobGenerator(column.name, column.isNullable)
        )
      of rdbBoolean:
        columnString.add(
          boolGenerator(
            column.name,
            column.isNullable,
            column.isDefault,
            column.defaultBool
          )
        )
      of rdbEnumField:
        columnString.add(
          enumGenerator(
            column.name,
            column.info["options"].getElems,
            column.isNullable,
            column.isDefault,
            column.defaultString
          )
        )
      of rdbJson:
        columnString.add(
          jsonGenerator(
            column.name,
            column.isNullable
          )
        )
      of rdbForeign:
        columnString.add(
          foreignColumnGenerator(column.name)
        )
        foreignString.add(
          foreignGenerator(
            column.name,
            column.info["table"].getStr(),
            column.info["column"].getStr(),
            column.foreignOnDelete
          )
        )

  var query = &"CREATE TABLE {this.name} ({columnString}{foreignString})"
  return query

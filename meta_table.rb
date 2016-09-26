module OpenType
  class MetaTable < BinData::Record
    class DataMapRecord < BinData::Record
      endian :big

      string :tag, length: 4
      uint32 :dataOffset
      uint32 :dataLength
    end


    endian :big

    uint16 :majorVersion
    uint16 :minorVersion
    uint32 :flags
    uint32 :_reserved
    uint32 :dataMapsCount

    # TODO, adding a new datamap requires adding a new dataMapRecord
    # data map records might be required to be sorted alphabetically too, ugh.
    array :dataMapRecords, initial_length: :dataMapsCount, type: :data_map_record

    array :tag_values, initial_length: :dataMapsCount do
      string nil, read_length: lambda {
        sorted_data_map_records = dataMapRecords.sort_by { |record| record.offset }
        sorted_data_map_records[index].dataLength
      }
    end

    def [](key)
      index = dataMapRecords.sort_by { |record| record.offset }.index { |record| record.tag == key.to_s }
      return nil if index.nil?

      data[index]
    end

    def []=(key, value)
      # ugh, ALL offsets need to be rewritten. Not so bad actually though. Oh shit the PARENT's
      # offsets need to be rewritten too though.
      index = dataMapRecords.sort_by { |record| record.offset }.index { |record| record.tag == key.to_s }


      reindex_directory
    end
    def reindex_directory
      dataMapRecords.each_with_index do |record, index|
        value = data[index]

        record.dataOffset =
        record.dataLength = value.length
        # parent.reindex_directory
      end
    end
  end
end

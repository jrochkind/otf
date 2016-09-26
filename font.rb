require 'bindata'
require 'open_type/table_record'
require 'open_type/meta_table'

module OpenType
  class Font < BinData::Record
    endian :big

    uint32 :sfntVersion
    uint16 :numTables
    uint16 :searchRange # TODO needs to be calculated when data changes?
    uint16 :entrySelector # TODO needs to be calculated when data changes?
    uint16 :rangeShift # TODO needs to be calculated when data changes?

    array :table_records, initial_length: :numTables, type: :table_record

    virtual :table_records_sorted_by_offset, value: lambda { table_records.sort_by { |table_record| table_record.offset } }

    #Note: This function implies that the length of a table must be a multiple of four bytes.
    # In fact, a font is not considered structurally proper without the correct padding.
    # All tables must begin on four byte boundries, and any remaining space between tables is
    # padded with zeros. The length of all tables should be recorded in the table record
    # with their actual length (not their padded length).
    # TODO: Pad properly on output, ugh!

    # 'Entries in the Table Record must be sorted in ascending order by tag'
    # But the tables themselves NOT neccesarily!!!


    # Okay, this is reading all the tables but as opaque binary data. We need to somehow
    # make some of them be specific classes, like one for Metadata. Working up to it with
    # the 'choice' -- not sure if this works.
    array :tables, initial_length: :numTables do
      choice selection: lambda { table_records.sort_by { |table_record| table_record.offset }[index].tag } do
        # recognize the table type and use a custom class?
        #meta_table 'meta'

        # opaque binary data as default case
        string :default, byte_align: 4, read_length: lambda {
          # very inefficient that we're doing this each iteration, bah
          sorted_table_records = table_records.sort_by { |table_record| table_record.offset }
          sorted_table_records[index].tableLength
        }
      end
    end
  end
end

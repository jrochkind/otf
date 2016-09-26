module OpenType
  class TableRecord < BinData::Record
    class_attribute :table_tag_classes
    self.table_tag_classes = {
      'meta' => :meta
    }

    endian :big

    string :tag, length: 4
    uint32 :checkSum # TODO, needs calc on change
    uint32 :offset # from beginning of file, TODO needs calc on change
    # spec `length` is a reserved word, `tableLength` instead.
    uint32 :tableLength # TODO needs calc on change
  end
end

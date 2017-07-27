# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

module TwitterCldr
  module Resources
    module Properties

      class UnicodeDataPropertiesImporter < PropertyImporter
        DATA_URL = 'ucd/UnicodeData.txt'

        PROPERTIES = {
          2  => 'General_Category',
          3  => 'Canonical_Combining_Class',
          4  => 'Bidi_Class',
          7  => 'Numeric_Type',
          9  => 'Bidi_Mirrored',
        }

        def initialize(input_path, database)
          super(
            input_path: input_path,
            property_name: nil,
            data_url: DATA_URL,
            data_path: File.basename(DATA_URL),
            database: database
          )
        end

        private

        def load
          range_start = nil

          super do |data, ret|
            code_points = expand_range(data[0])

            # UnicodeData.txt can contain ranges of characters
            # specified with "First" and "Last" identifiers in
            # the name field.
            if data[1].include?(', First')
              range_start = code_points.first
              next
            elsif data[1].include?(', Last')
              code_points = (range_start..code_points.first).to_a
              range_start = nil
            end

            PROPERTIES.each_pair do |idx, property_name|
              property_value = format_property_value(data[idx])
              ret[property_name][property_value] += code_points
            end
          end
        end
      end

    end
  end
end

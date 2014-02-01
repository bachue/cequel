module Cequel
  module Metal
    #
    # Encapsulates an `INSERT` statement
    #
    # @see DataSet#insert
    # @since 1.0.0
    #
    class Inserter < Writer
      #
      # (see Writer#initialize)
      #
      def initialize(data_set, options = {})
        @row = {}
        super
      end

      #
      # (see Writer#execute)
      #
      def execute
        statement = Statement.new
        write_to_statement(statement)
        data_set.write(*statement.args)
      end

      #
      # Insert the given data into the table
      #
      # @param data [Hash<Symbol,Object>] map of column names to values
      # @return [void]
      #
      def insert(data)
        @row.merge!(data.symbolize_keys)
      end

      private

      attr_reader :row

      def column_names
        row.keys
      end

      def statements
        [].tap do |statements|
          row.each_pair do |column_name, value|
            column_names << column_name
            prepare_upsert_value(value) do |statement, *values|
              statements << statement
              bind_vars.concat(values)
            end
          end
        end
      end

      def write_to_statement(statement)
        statement.append("INSERT INTO #{table_name}")
        statement.append(
          " (#{column_names.join(', ')}) VALUES (#{statements.join(', ')}) ",
          *bind_vars)
        statement.append(generate_upsert_options)
      end
    end
  end
end

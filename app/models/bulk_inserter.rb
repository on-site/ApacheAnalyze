class BulkInserter < Struct.new :model
  def create(columns, values)
    values = values.map do |record|
      record.map do |value|
        if value == :now
          now
        else
          connection.quote value
        end
      end
    end

    if sqlite?
      create_sqlite columns, values
    else
      create_other columns, values
    end
  end

  def bulk_size
    if sqlite?
      250
    else
      1000
    end
  end

  private
  def sqlite?
    connection.adapter_name == "SQLite"
  end

  def connection
    model.connection
  end

  def table_name
    model.table_name
  end

  def now
    @now ||= connection.quote(DateTime.now)
  end

  def create_sqlite(columns, values)
    values = values.map do |record|
      row = []

      columns.each_with_index do |column, i|
        row << "#{record[i]} AS #{column}"
      end

      "SELECT #{row.join ", "}"
    end

    connection.execute "INSERT INTO #{table_name}(#{columns.join ","}) #{values.join " UNION "}"
  end

  def create_other(columns, values)
    values = values.map do |record|
      "(#{record.join ","})"
    end

    connection.execute "INSERT INTO #{table_name}(#{columns.join ","}) VALUES #{values.join ","}"
  end
end

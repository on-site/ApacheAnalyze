class Source < ActiveRecord::Base
  SOURCE_DIR = File.join Rails.root, "analyze"
  VALID_FILENAME = /^[-_.a-zA-Z0-9]+$/

  has_many :entries
  has_many :parsed_entries, class_name: "Entry", conditions: { parsed: true }
  has_many :unparsed_entries, class_name: "Entry", conditions: { parsed: false }
  attr_accessor :non_analyzed
  validates_format_of :filename, with: VALID_FILENAME

  def recalculate_counts_if_needed!
    if count_entries.nil? || count_parsed_entries.nil? || count_unparsed_entries.nil?
      recalculate_counts!
    end
  end

  def recalculate_counts!
    self.count_entries = entries.size
    self.count_parsed_entries = parsed_entries.size
    self.count_unparsed_entries = unparsed_entries.size
    save!
  end

  def source_path
    if loaded?
      Rails.application.routes.url_helpers.source_path self
    else
      "#{Rails.application.routes.url_helpers.source_path -1}?filename=#{filename}"
    end
  end

  def example_row
    if non_analyzed
      File.open path, &:readline
    elsif entry_count > 0
      entries.limit(1).first.original
    end
  end

  def parsed_examples
    unless non_analyzed
      parsed_entries.limit(10).all
    end
  end

  def unparsed_examples
    unless non_analyzed
      unparsed_entries.limit(10).all
    end
  end

  def entry_count
    if loaded?
      recalculate_counts_if_needed!
      count_entries
    else
      return @_entry_count if @_entry_count
      @_entry_count = 0

      File.foreach path do |line|
        @_entry_count += 1 if line.present?
      end

      @_entry_count
    end
  end

  def parsed_entry_count
    if loaded?
      recalculate_counts_if_needed!
      count_parsed_entries
    end
  end

  def unparsed_entry_count
    if loaded?
      recalculate_counts_if_needed!
      count_unparsed_entries
    end
  end

  def has_more_to_parse?
    loaded? && unparsed_entry_count > 0
  end

  def finished_parsing?
    loaded? && unparsed_entry_count == 0
  end

  def path
    File.join SOURCE_DIR, filename
  end

  def exists?
    File.file? path
  end

  def loaded?
    !non_analyzed
  end

  def load!(options = {})
    inserter = BulkInserter.new(Entry)

    if options[:regex] && options[:groups]
      raise "regex is required!" if options[:regex].blank?
      raise "groups is required!" if options[:groups].blank?
      columns = Entry::PARSED_COLUMNS
      regex = Regexp.new options[:regex]
      groups = options[:groups].split(",").map(&:strip).map(&:to_sym)

      each_path_slice inserter.bulk_size do |lines|
        lines = lines.map do |line|
          result = Entry.parse! self, line, regex, groups
          columns.map do |column|
            if column == :created_at || column == :updated_at
              :now
            else
              result[column]
            end
          end
        end

        inserter.create columns, lines
      end
    else
      each_path_slice inserter.bulk_size do |lines|
        lines = lines.map do |line|
          [id, line, :now, :now]
        end

        inserter.create [:source_id, :original, :created_at, :updated_at], lines
      end
    end

    recalculate_counts!
  end

  def parse!(regex, groups, options = {})
    raise "regex is required!" if regex.blank?
    raise "groups is required!" if groups.blank?
    regex = Regexp.new regex
    groups = groups.split(",").map(&:strip).map(&:to_sym)

    if options[:force]
      conditions = { source_id: id }
    else
      conditions = { source_id: id, parsed: false }
    end

    Entry.where(conditions).find_in_batches do |values|
      values.each do |entry|
        entry.parse! regex, groups, options
      end
    end

    recalculate_counts!
  end

  def delete_file!
    File.delete path
  end

  def drop_data!
    Entry.delete_all source_id: id
    destroy
  end

  class << self
    def with_parsed
      all.select do |source|
        source.parsed_entry_count > 0
      end
    end

    def upload!(file)
      filename = file.original_filename
      filename.gsub! /^.*(\\|\/)/, ""
      raise "Invalid filename #{filename}" if filename == "." || filename == ".."
      raise "Invalid filename #{filename}" unless filename =~ VALID_FILENAME
      path = File.join SOURCE_DIR, filename
      addon = 2

      while File.file? path
        path = File.join SOURCE_DIR, "#{filename}.#{addon}"
        addon += 1
      end

      File.open path, "w" do |f|
        f.write file.read
      end
    end

    def load!(filename, options = {})
      raise "filename '#{filename}' is not valid!" unless valid_filename? filename
      existing = Source.where(filename: filename).first
      raise "That source has already been loaded..." if existing
      source = Source.create! filename: filename
      source.load! options
      source
    end

    # All + all non-analyzed
    def everything
      (all + non_analyzed).sort { |a, b| a.filename <=> b.filename }
    end

    def non_analyzed
      grouped = {}

      select(:filename).group(:filename).each do |item|
        grouped[item.filename] = true
      end

      existing = files

      existing = existing.select do |file|
        !grouped[file.filename]
      end

      existing.each do |file|
        file.non_analyzed = true
      end

      existing
    end

    def raw_files
      results = []

      Dir.foreach SOURCE_DIR do |file|
        next unless File.file? File.join(SOURCE_DIR, file)
        next if file == ".gitkeep"
        results << file
      end

      results
    end

    def files
      raw_files.map do |file|
        Source.new filename: file
      end
    end

    def from_file(id, filename)
      if id == -1
        raise "filename '#{filename}' is not valid!" unless valid_filename? filename
        result = Source.new filename: filename
        result.non_analyzed = true
        result
      else
        find id
      end
    end

    def valid_filename?(filename)
      return false if filename == "." || filename == ".."
      filename =~ VALID_FILENAME && raw_files.include?(filename)
    end
  end

  private
  # Iterate over each n stripped lines in the file defined by path.
  def each_path_slice(n)
    temp = []
    File.foreach path do |line|
      line.strip!
      temp << line unless line.blank?

      if temp.length >= n
        yield temp
        temp.clear
      end
    end

    yield temp unless temp.empty?
  end
end

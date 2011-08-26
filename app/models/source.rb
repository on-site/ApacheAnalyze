class Source < ActiveRecord::Base
  SOURCE_DIR = File.join Rails.root, "analyze"

  has_many :entries
  has_many :parsed_entries, :class_name => "Entry", :conditions => { :parsed => true }
  has_many :unparsed_entries, :class_name => "Entry", :conditions => { :parsed => false }
  attr_accessor :non_analyzed
  validates_format_of :filename, :with => /^[-_.a-zA-Z0-9]+$/

  def entry_count
    if loaded?
      entries.size
    end
  end

  def parsed_entry_count
    if loaded?
      parsed_entries.size
    end
  end

  def unparsed_entry_count
    if loaded?
      unparsed_entries.size
    end
  end

  def has_more_to_parse?
    loaded? && unparsed_entry_count > 0
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

  def load!
    File.foreach path do |line|
      line.strip!
      next if line.blank?
      Entry.create! :source_id => id, :original => line
    end
  end

  def parse!(regex, groups)
    raise "regex is required!" if regex.blank?
    raise "groups is required!" if groups.blank?
    regex = Regexp.new regex
    groups = groups.split(",").map(&:strip)

    unparsed_entries.each do |entry|
      entry.parse! regex, groups
    end
  end

  class << self
    def load!(filename)
      raise "filename is required!" unless filename.present?
      raise "filename '#{filename}' is not valid!" unless valid_filename? filename
      existing = Source.where(:filename => filename).first
      raise "That source has already been loaded..." if existing
      source = Source.create! :filename => filename
      source.load!
      source
    end

    # All + all non-analyzed
    def everything
      (all + non_analyzed).sort { |a, b| a.filename <=> b.filename }
    end

    def non_analyzed
      grouped = {}

      group(:filename).each do |item|
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
        Source.new :filename => file
      end
    end

    def valid_filename?(filename)
      raw_files.include? filename
    end
  end
end

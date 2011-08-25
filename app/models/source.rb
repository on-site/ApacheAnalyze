class Source < ActiveRecord::Base
  SOURCE_DIR = File.join Rails.root, "analyze"

  attr_accessor :non_analyzed
  validates_format_of :filename, :with => /^[-_.a-zA-Z0-9]+$/

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
      next if line.blank?
      Entry.create! :source_id => id, :original => line
    end
  end

  class << self
    def load!(filename)
      raise "filename is required!" unless filename.present?
      raise "filename '#{filename}' is not valid!" unless valid_filename? filename
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

      group(:filename).each do |key, value|
        grouped[key] = value
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

class Source < ActiveRecord::Base
  attr_accessor :non_analyzed
  SOURCE_DIR = File.join Rails.root, "analyze"

  class << self
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

    def files
      results = []

      Dir.foreach SOURCE_DIR do |file|
        next unless File.file? File.join(SOURCE_DIR, file)
        next if file == ".gitkeep"
        results << file
      end

      results.map do |file|
        Source.new :filename => file
      end
    end
  end
end

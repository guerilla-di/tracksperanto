# Finds a suitable importer for the chosen file path. Or at least tries to, based on the file extension.
# Will then examine all the importers and ask them if they can handle the specified file
class Tracksperanto::FormatDetector
  
  def initialize(with_path)
    perform_detection(with_path)
    freeze
  end
  
  private
    def perform_detection(for_path)
      return unless (for_path && !for_path.to_s.empty?)
      ext = File.extname(for_path.downcase)
      @importer_klass = Tracksperanto.importers.find{ |i| i.distinct_file_ext == ext }
    end
  
  public
    
    # Tells if an importer has been found for this extension
    def match?
      !!@importer_klass
    end
    
    # Returns the importer if there is one
    def importer_klass
      @importer_klass
    end
    
    # Tells if comp size needs to be provided
    def auto_size?
      match? ? importer_klass.autodetects_size? : false
    end
    
    # Returns the human name of the importer
    def human_importer_name
      match? ? importer_klass.human_name : "Unknown format"
    end
end
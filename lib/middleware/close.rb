class Tracksperanto::Middleware::Close < Tracksperanto::Middleware::Base
  def end_export
    super
    @exporter.close! if @exporter.respond_to?(:close)
  end
end
class Tracksperanto::Middleware::Close < Tracksperanto::Middleware::Base
  def end_export
    super
    @exporter.io.close if @exporter.respond_to?(:io)
  end
end
# We make use of the implementation details of the progress bar to also show our current status
class Tracksperanto::PBar < ::ProgressBar
  
  def fmt_title
    "%20s" % @title
  end
  
  def set_with_message(pcnt, message)
    @title = message
    set(pcnt)
  end
  
end
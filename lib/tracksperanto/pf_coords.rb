module Tracksperanto::PFCoords
  def to_pfcoord(xperanto_value)
    xperanto_value.to_f - 0.5
  end
  
  def from_pfcoord(pf_value)
    pf_value.to_f + 0.5
  end
end
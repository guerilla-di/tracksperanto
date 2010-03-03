module Tracksperanto::Returning
  # The "returning" idiomn copied from ActiveSupport
  def returning(r)
    yield(r); r
  end
end
# -*- encoding : utf-8 -*-
module Tracksperanto::Returning
  # The "returning" idiom copied from ActiveSupport
  def returning(r)
    yield(r); r
  end
end

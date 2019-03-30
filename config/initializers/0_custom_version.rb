# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    def flavor
      '+slice'
    end

    def repository
      'slice/slicedon'
    end
  end
end

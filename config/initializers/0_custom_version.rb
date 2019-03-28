# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    def flags
      '+slice'
    end

    def repository
      'slice/slicedon'
    end
  end
end

module Differ
  module Format
    module CLEAN_HTML
      class << self
        def format(change)
          (change.change? && as_change(change)) ||
          (change.delete? && as_delete(change)) ||
          (change.insert? && as_insert(change)) ||
          ''
        end

      private
        def as_insert(change)
          %Q{<ins>#{change.insert}</ins>}
        end

        def as_delete(change)
          %Q{<del>#{change.delete}</del>}
        end

        def as_change(change)
          as_delete(change) << as_insert(change)
        end
      end
    end
  end
end

# Set default format for Differ
Differ.format = Differ::Format::CLEAN_HTML

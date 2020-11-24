class OptparseBuilder

  module StableSort # :nodoc:

    module_function

    def stable_sort_by!(a)
      a.sort_by!.with_index do |e, i|
        [yield(e), i]
      end
    end
    
  end
end

# frozen_string_literal: true

module ConservationGuardian
  class Budget
    attr_reader :limits, :name

    # limits: Hash of { category_name => max_value }
    def initialize(name: "default", limits: {})
      @name   = name
      @limits = limits.transform_keys(&:to_sym)
      freeze
    end

    def limit_for(category)
      @limits[category.to_sym]
    end

    def exceeded?(category, value)
      max = limit_for(category)
      return false if max.nil?

      value > max
    end

    def categories
      @limits.keys
    end

    def to_h
      { name: @name, limits: @limits.dup }
    end
  end
end

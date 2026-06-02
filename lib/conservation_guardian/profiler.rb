# frozen_string_literal: true

module ConservationGuardian
  class Profiler
    attr_reader :samples, :budget

    def initialize(budget)
      @budget  = budget
      @samples = []
    end

    # samples: Array of { category:, value:, label: }
    # or pass a single sample at a time
    def ingest(samples)
      samples = [samples] if samples.is_a?(Hash)
      samples.each do |s|
        @samples << {
          category: s[:category].to_sym,
          value:    s[:value].to_f,
          label:    s[:label].to_s,
          timestamp: Time.now
        }
      end
    end

    def stats_for(category)
      cat = category.to_sym
      vals = @samples.select { |s| s[:category] == cat }.map { |s| s[:value] }
      return nil if vals.empty?

      {
        count: vals.size,
        min:   vals.min,
        max:   vals.max,
        sum:   vals.sum,
        avg:   vals.sum / vals.size
      }
    end

    def all_stats
      @samples.map { |s| s[:category] }.uniq.each_with_object({}) do |cat, h|
        h[cat] = stats_for(cat)
      end
    end

    def over_budget_samples
      @samples.select { |s| @budget.exceeded?(s[:category], s[:value]) }
    end

    def clear!
      @samples.clear
    end
  end
end

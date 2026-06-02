# frozen_string_literal: true

module ConservationGuardian
  class Detector
    attr_reader :budget, :profiler

    def initialize(budget, profiler)
      @budget   = budget
      @profiler = profiler
    end

    def detect
      findings = []
      findings.concat(detect_over_budget)
      findings.concat(detect_anomalies)
      findings
    end

    private

    def detect_over_budget
      profiler.over_budget_samples.map do |sample|
        {
          type:       :over_budget,
          severity:   :high,
          category:   sample[:category],
          value:      sample[:value],
          limit:      budget.limit_for(sample[:category]),
          label:      sample[:label],
          message:    "#{sample[:label]} (#{sample[:value]}) exceeds limit #{budget.limit_for(sample[:category])} for #{sample[:category]}"
        }
      end
    end

    def detect_anomalies
      findings = []
      profiler.samples.map { |s| s[:category] }.uniq.each do |cat|
        stats = profiler.stats_for(cat)
        next unless stats && stats[:count] >= 2

        threshold = stats[:avg] * 2
        profiler.samples.select { |s| s[:category] == cat && s[:value] > threshold }.each do |sample|
          findings << {
            type:     :anomaly,
            severity: :medium,
            category: cat,
            value:    sample[:value],
            avg:      stats[:avg],
            label:    sample[:label],
            message:  "#{sample[:label]} (#{sample[:value]}) is >2x the average (#{stats[:avg].round(2)}) for #{cat}"
          }
        end
      end
      findings
    end
  end
end

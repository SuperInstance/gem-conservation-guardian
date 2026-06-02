# frozen_string_literal: true

module ConservationGuardian
  class Report
    attr_reader :budget, :profiler, :findings

    def initialize(budget, profiler, findings)
      @budget   = budget
      @profiler = profiler
      @findings = findings
    end

    def to_h
      {
        budget:   budget.to_h,
        stats:    profiler.all_stats,
        findings: findings,
        summary:  summary
      }
    end

    def summary
      {
        total_samples: profiler.samples.size,
        total_findings: findings.size,
        over_budget: findings.count { |f| f[:type] == :over_budget },
        anomalies: findings.count { |f| f[:type] == :anomaly },
        categories_checked: budget.categories.size
      }
    end

    def to_s
      lines = []
      lines << "=== Conservation Guardian Report ==="
      lines << "Budget: #{budget.name}"
      lines << "Samples analyzed: #{summary[:total_samples]}"
      lines << "Findings: #{summary[:total_findings]} (#{summary[:over_budget]} over budget, #{summary[:anomalies]} anomalies)"
      lines << ""

      if findings.any?
        lines << "--- Findings ---"
        findings.each do |f|
          lines << "[#{f[:severity].upcase}] #{f[:message]}"
        end
      else
        lines << "✅ No waste detected. All clear!"
      end

      lines.join("\n")
    end
  end
end

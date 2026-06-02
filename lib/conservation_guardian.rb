# frozen_string_literal: true

require_relative "conservation_guardian/budget"
require_relative "conservation_guardian/profiler"
require_relative "conservation_guardian/detector"
require_relative "conservation_guardian/report"

module ConservationGuardian
  class Error < StandardError; end

  # Convenience: run the full pipeline and return a Report
  def self.analyze(budget:, samples:)
    profiler = Profiler.new(budget)
    profiler.ingest(samples)
    detector = Detector.new(budget, profiler)
    findings = detector.detect
    Report.new(budget, profiler, findings)
  end
end

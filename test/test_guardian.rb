# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/conservation_guardian"

class TestBudget < Minitest::Test
  def setup
    @budget = ConservationGuardian::Budget.new(
      name: "test_budget",
      limits: { memory: 512, cpu: 80, disk: 1000 }
    )
  end

  def test_limit_for
    assert_equal 512, @budget.limit_for(:memory)
    assert_equal 80, @budget.limit_for("cpu")
  end

  def test_limit_for_unknown
    assert_nil @budget.limit_for(:unknown)
  end

  def test_exceeded
    assert @budget.exceeded?(:memory, 600)
    refute @budget.exceeded?(:memory, 400)
    refute @budget.exceeded?(:unknown, 9999)
  end

  def test_categories
    assert_equal %i[memory cpu disk], @budget.categories
  end

  def test_frozen
    assert @budget.frozen?
  end
end

class TestProfiler < Minitest::Test
  def setup
    @budget = ConservationGuardian::Budget.new(limits: { memory: 100 })
    @profiler = ConservationGuardian::Profiler.new(@budget)
  end

  def test_ingest_single
    @profiler.ingest({ category: :memory, value: 50, label: "process_a" })
    assert_equal 1, @profiler.samples.size
  end

  def test_ingest_array
    @profiler.ingest([
      { category: :memory, value: 50, label: "a" },
      { category: :memory, value: 120, label: "b" }
    ])
    assert_equal 2, @profiler.samples.size
  end

  def test_stats_for
    @profiler.ingest([
      { category: :memory, value: 10, label: "a" },
      { category: :memory, value: 30, label: "b" },
      { category: :memory, value: 50, label: "c" }
    ])
    stats = @profiler.stats_for(:memory)
    assert_equal 3, stats[:count]
    assert_equal 10, stats[:min]
    assert_equal 50, stats[:max]
    assert_equal 30, stats[:avg]
  end

  def test_over_budget_samples
    @profiler.ingest([
      { category: :memory, value: 50, label: "a" },
      { category: :memory, value: 120, label: "b" }
    ])
    over = @profiler.over_budget_samples
    assert_equal 1, over.size
    assert_equal 120, over.first[:value]
  end
end

class TestDetector < Minitest::Test
  def setup
    @budget = ConservationGuardian::Budget.new(limits: { memory: 100 })
    @profiler = ConservationGuardian::Profiler.new(@budget)
  end

  def test_detect_over_budget
    @profiler.ingest([
      { category: :memory, value: 50, label: "a" },
      { category: :memory, value: 150, label: "b" }
    ])
    detector = ConservationGuardian::Detector.new(@budget, @profiler)
    findings = detector.detect
    over = findings.select { |f| f[:type] == :over_budget }
    assert_equal 1, over.size
    assert_equal :high, over.first[:severity]
  end

  def test_detect_anomaly
    @profiler.ingest([
      { category: :memory, value: 10, label: "a" },
      { category: :memory, value: 10, label: "b" },
      { category: :memory, value: 10, label: "c" },
      { category: :memory, value: 90, label: "d" }
    ])
    detector = ConservationGuardian::Detector.new(@budget, @profiler)
    findings = detector.detect
    anomalies = findings.select { |f| f[:type] == :anomaly }
    assert anomalies.size >= 1
  end
end

class TestReport < Minitest::Test
  def test_report_summary
    budget = ConservationGuardian::Budget.new(name: "test", limits: { memory: 100 })
    report = ConservationGuardian.analyze(
      budget: budget,
      samples: [
        { category: :memory, value: 50, label: "a" },
        { category: :memory, value: 150, label: "b" }
      ]
    )
    assert_equal 2, report.summary[:total_samples]
    assert report.summary[:total_findings] >= 1
    assert_match(/Conservation Guardian Report/, report.to_s)
  end
end

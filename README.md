# Conservation Guardian

Universal **Budget → Profile → Detect → Report** pattern for resource conservation in any Ruby project.

## Installation

```bash
gem install conservation-guardian
```

## Usage

```ruby
require "conservation_guardian"

# Define a budget
budget = ConservationGuardian::Budget.new(
  name: "server_resources",
  limits: { memory_mb: 512, cpu_percent: 80 }
)

# Profile usage
profiler = ConservationGuardian::Profiler.new(budget)
profiler.ingest([
  { category: :memory_mb, value: 200, label: "worker_1" },
  { category: :memory_mb, value: 600, label: "worker_2" },
  { category: :cpu_percent, value: 45, label: "worker_1" },
  { category: :cpu_percent, value: 95, label: "worker_2" }
])

# Detect waste
detector = ConservationGuardian::Detector.new(budget, profiler)
findings = detector.detect

# Generate report
report = ConservationGuardian::Report.new(budget, profiler, findings)
puts report

# Or use the convenience method
report = ConservationGuardian.analyze(budget: budget, samples: samples)
```

## API

### Budget

Defines resource limits by category.

```ruby
budget = ConservationGuardian::Budget.new(name: "limits", limits: { memory: 512 })
budget.exceeded?(:memory, 600)  # => true
budget.limit_for(:memory)       # => 512
```

### Profiler

Tracks usage samples per category.

```ruby
profiler.ingest({ category: :memory, value: 200, label: "process" })
profiler.stats_for(:memory)  # => { count:, min:, max:, sum:, avg: }
```

### Detector

Finds over-budget and anomalous usage.

```ruby
detector.detect  # => [{ type: :over_budget, severity: :high, ... }]
```

### Report

Human-readable and machine-parseable output.

```ruby
report.to_h      # => Hash with budget, stats, findings, summary
report.to_s      # => formatted text
report.summary   # => { total_samples:, total_findings:, ... }
```

## License

MIT

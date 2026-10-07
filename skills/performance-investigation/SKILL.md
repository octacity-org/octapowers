---
name: performance-investigation
description: Investigate or improve software performance through open-ended optimization or a specific performance target. Use for latency, throughput, CPU, memory, allocation, startup, build-time, bundle-size, network, scaling, or performance regressions, including requests to satisfy an explicit metric. Measure representative behavior, test concrete bottleneck hypotheses, preserve correctness, and verify targets without speculative claims.
---

# Investigate Performance with Measurements

Optimize an observed constraint, not an imagined one. Scale the investigation to the problem and distinguish correctness evidence from performance evidence.

## Define the Target

Determine whether the request is open-ended optimization or a specific performance target. Define:

- the user-visible or operational problem;
- the exact metric and direction;
- the threshold or meaningful improvement;
- the workload, data shape, scale, concurrency, and environment;
- the sampling duration or count and statistical summary;
- correctness, memory, error-rate, complexity, compatibility, or cost guardrails.

Choose a metric that matches the symptom: p50, p95, or p99 latency rather than only an average; peak or retained memory rather than only allocation count; clean and incremental build time separately.

Treat a user-specified metric as an acceptance criterion. Do not silently weaken a user-specified target. Infer routine details from the project and deployed environment; ask only when a missing condition would materially change the target. If direct measurement is unavailable, use the closest defensible proxy and state the limitation.

If the user asks only for investigation or analysis, do not modify production code.

## Scale the Investigation

- **Small/local:** use one repeatable timing, size, or allocation measurement plus a correctness check.
- **Moderate:** use a representative benchmark, profile or trace, multiple samples, and adjacent-metric checks.
- **System-wide:** use a production-like workload, end-to-end tracing, saturation and concurrency analysis, load testing, and explicit environmental controls.

Do not run disruptive load tests against production or shared systems without appropriate user authority.

## Establish a Baseline

Measure current behavior before optimizing:

1. Use the smallest benchmark, trace, profiler, or system measurement that represents the problem.
2. Record the workload, environment, configuration, command, build mode, dependency state, and result.
3. Verify that build mode and runtime configuration represent the target environment. Do not draw production conclusions from debug or development builds unless that behavior is the target.
4. Confirm that benchmark outputs are consumed, work is not optimized away, caches are in the intended state, setup is separated when appropriate, and fixtures preserve realistic data shape and size.
5. Control obvious noise. Include warm-up when needed and report the sample count with an appropriate summary such as median, percentiles, range, or confidence interval. Do not discard outliers without explaining why.
6. Preserve a correctness check for behavior the optimization must not change.

For a regression, compare against a known-good revision or configuration when available. Determine when the slowdown appeared and separate code changes from workload, dependency, hardware, operating-system, build-mode, runtime, configuration, and measurement-tool changes. Bisect only with a stable, repeatable signal.

Do not use an unrepresentative microbenchmark as proof of end-to-end improvement.

## Locate the Bottleneck

Inspect relevant profiles, traces, query plans, allocation data, I/O timing, network waterfalls, bundle analysis, or system counters.

Form one concrete bottleneck hypothesis that explains the baseline. Test it with the smallest discriminating experiment. If rejected, revise the model instead of stacking speculative optimizations.

Improve the dominant cost rather than code that is merely easy to change. Consider algorithms, unnecessary computation or allocation, blocking, contention, I/O, caching, batching, data layout, serialization, and transferred bytes only when evidence points there.

## Implement Proportionally

Make the smallest change that tests the confirmed hypothesis.

- Preserve correctness, error behavior, compatibility, and resource limits.
- Include invalidation, staleness, and memory growth when adding caches.
- Include contention, ordering, and backpressure when increasing concurrency.
- Avoid trading a measured bottleneck for an unbounded resource cost.
- Accept added complexity only for a demonstrated, worthwhile improvement.

Behavior-preserving optimizations use existing correctness coverage and before-and-after measurements. Add focused coverage for important unprotected behavior. Use test-driven development for intentional behavior changes or correctness fixes unless the user overrides it. Do not treat a noisy benchmark threshold as an ordinary correctness test unless it is stable enough for reliable automation.

## Compare, Stop, and Report

Compare before and after using the same workload, metric, environment, build mode, and measurement method. Repeat noisy measurements and use the same statistical summary.

Verify:

1. relevant correctness checks still pass;
2. the requested target or improvement is demonstrated;
3. important adjacent metrics and guardrails did not regress materially;
4. the original user-visible or operational symptom improved when reproducible.

Stop when the stated target is met, the remaining cost is no longer dominant, or further gains require disproportionate complexity, resources, or unauthorized tradeoffs. Record remaining opportunities instead of implementing them speculatively.

If a specific target cannot be met, report the baseline, best achieved value, remaining gap, limiting evidence, and what further tradeoff or change would be required. Otherwise report the before-and-after result, method, scope, and uncertainty. Distinguish local benchmark evidence from system-wide evidence. Do not claim an improvement without fresh measurements.

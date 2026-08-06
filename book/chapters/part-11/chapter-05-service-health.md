## 11.5 - Service Health {#chapter-11-05}

SLIs measure user-visible behavior, SLOs set target levels, and SLAs are external commitments with defined consequences. Good SLIs measure successful, sufficiently fast, correct operations at the boundary users care about.

Availability ratios require a valid denominator. For request services, count eligible requests; for batch systems, measure completion by deadline; for pipelines, measure freshness and correctness. Exclude traffic only by an explicit policy that cannot hide failure.

An error budget is the allowed unreliability implied by the SLO. Burn-rate alerts detect consumption fast enough to act while avoiding noise from insignificant blips. Combine a fast, high-burn window with a slower confirmation window.

Health endpoints have different purposes. Liveness asks whether restart may help. Readiness asks whether to route traffic. Startup protects slow initialization. A dependency outage should not necessarily fail liveness and create a fleet restart storm.

Capacity signals—utilization, saturation, queueing, headroom, and forecast—complement outcome SLIs. Report SLOs by critical journey and tenant where aggregation would hide harm.

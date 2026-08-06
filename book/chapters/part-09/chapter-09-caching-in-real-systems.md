## 9.9 - Caching in Real Systems {#chapter-09-09}

A cache trades freshness and complexity for lower latency, lower load, or availability. Define the key, value, authority, freshness, capacity, eviction, and behavior on failure before choosing a product.

Cache-aside reads the cache, loads the authority on miss, and writes the cache. Write-through updates cache and authority in one path but still has failure ordering. Write-behind improves write latency while risking loss and stale authority. Refresh-ahead hides misses for predictable hot data.

TTL limits age; it does not guarantee invalidation immediately or prevent an old writer repopulating stale data. Versioned keys, compare-and-set, event invalidation, and single-flight request coalescing address different races. Add jitter to expirations to prevent synchronized stampedes; use admission/eviction so scans do not evict the hot set.

Negative caching can protect a missing lookup but may hide newly created data. Distributed caches also introduce network latency, serialization, hot keys, and a new outage mode. A fallback to the database can turn cache failure into database failure, so bound fallback concurrency.

Cache hit rate alone is insufficient: measure saved origin work, hit latency, staleness, evictions, key skew, and behavior during cold start.

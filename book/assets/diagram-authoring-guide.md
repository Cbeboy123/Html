# Diagram authoring contract

This file is build guidance, not assembled book content.

Use a diagram for spatial relationships, ordered interactions, state changes, or
three or more components whose connections matter. Prefer a table for exact
mappings and pairwise contrasts. Do not duplicate a list as a picture.

- Match reading order: left-to-right for pipelines, top-to-bottom for decisions.
- Keep labels short and move explanation into the surrounding prose.
- Prefer one main direction and avoid crossing edges.
- Use subgraphs only for a named trust, ownership, deployment, or failure boundary.
- Split a diagram before labels become cramped or the SVG needs excessive scaling.
- Keep each diagram on one A4 page.
- Use only the shapes and line semantics in the master legend.
- Add an italic line below every diagram beginning with `Diagram key:`.
- Do not add color-dependent class rules.

Required coverage includes the URL journey and latency ledger; TCP, TLS 1.3, and
DNS; virtual memory and false sharing; database WAL, MVCC, B+tree, and query
plans; Kafka layout, production, consumption, rebalancing, and replication; and
distributed quorums, fencing, sagas, outbox, and CDC. Part XII contrasts use
native Markdown tables.


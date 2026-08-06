[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$chapterRoot = Join-Path $root "book\chapters"

$parts = @(
  @("I","Computation, Data, and Runtime Foundations","Establish the physical and representational limits behind performance, correctness, and runtime behavior.",@("A Useful Cost Model of a Computer","Bits, Bytes, and Number Representation","Text Is Not Just Characters","Binary Data Across Machines","Floating-Point Reality","Compilation, Interpretation, and Runtimes","Complexity Without Coding Puzzles")),
  @("II","Operating Systems, Memory, and Concurrency","Explain what application code depends on once it meets processors, kernels, memory, files, and competing work.",@("Programs Become Processes","Threads, Tasks, and Scheduling","Stack, Heap, and Allocation","Garbage Collection from First Principles","Virtual Memory","CPU Caches and Shared Memory","The Memory Model","Synchronization and Liveness","Files, I/O, and Durability","Practical Linux and Isolation")),
  @("III","Networks and the Web","Build the packet-to-HTTP mental model needed to reason about latency, connectivity, load balancing, and web failures.",@("Networks as Layered Delivery","Local Networks","IP Addressing and Routing","DNS","TCP","UDP, QUIC, and Transport Tradeoffs","TLS 1.3 and HTTPS","HTTP","Network Intermediaries")),
  @("IV","What Happens When You Enter a URL","Turn the preceding foundations into one traceable end-to-end request, including delays and failures at every boundary.",@("Before the Network","Finding and Reaching the Destination","Across the Service","Returning and Rendering","A Latency and Failure Ledger")),
  @("V","APIs, Serialization, and Messaging","Teach service boundaries and compatibility before examining Kafka or broader distributed behavior.",@("Contracts Across Process Boundaries","Resource-Oriented HTTP APIs","RPC and gRPC","Asynchronous Messaging","Serialization Formats","Evolving an Interface")),
  @("VI","Database and Storage Fundamentals","Connect relational guarantees and query behavior to the storage, recovery, and concurrency machinery underneath them.",@("From Durable Bytes to a Database","The Relational Model","Normalization and Deliberate Denormalization","Transactions and ACID","Isolation and Concurrency Control","Indexes","Queries and Execution Plans","Scaling and Protecting Data","Choosing a Data Model")),
  @("VII","Kafka from First Principles","Give Kafka the deepest treatment while separating durable log concepts from version-dependent details.",@("Why a Distributed Log Exists","Topics, Partitions, Records, and Offsets","Broker and Cluster Anatomy","The Producer Path","The Consumer Path","Rebalancing and Consumer Failure","Replication and Recovery","Retention, Deletion, and Log Compaction","Storage and Throughput Mechanics","Delivery Semantics and Transactions","Metadata Evolution: ZooKeeper and KRaft","Operating Kafka","Kafka Interview Synthesis")),
  @("VIII","Object-Oriented and Modular Software Design","Rebuild code-level design judgment without turning the book into an LLD pattern catalog.",@("Why Abstraction Exists","The Four OOP Ideas Without Slogans","Composition, Inheritance, and Delegation","Coupling, Cohesion, and Dependency Direction","SOLID as Diagnostic Heuristics","State, Mutation, and Error Handling","Maintainable Change")),
  @("IX","Distributed Systems and Resilience","Teach how independent machines fail, coordinate, recover, and expose imperfect guarantees without designing a product.",@("Why Distribution Changes the Rules","Scalability, Availability, Reliability, and Fault Tolerance","Replication and Quorums","Failure Detection, Election, and Consensus","CAP, PACELC, and Consistency","Time in Distributed Systems","Timeouts, Retries, and Idempotency","Backpressure and Overload Control","Caching in Real Systems","Cross-System Consistency","High Availability and Safe Lifecycle")),
  @("X","Security Fundamentals","Provide enough security reasoning to recognize trust boundaries, choose standard mechanisms, and avoid homemade protection.",@("Threats, Assets, and Trust Boundaries","Cryptographic Building Blocks","Keys, Certificates, and TLS Trust","Authentication","Authorization","OAuth 2.0 and OpenID Connect","Browser and API Security","Operational Security")),
  @("XI","Engineering Excellence in Production","Connect correctness, delivery, observability, performance, and organizational judgment into a staff-level operating model.",@("Testing as Risk Control","Continuous Integration and Delivery","Safe Production Change","Observability","Service Health","Performance Engineering","Debugging and Root-Cause Analysis","Incidents and Recovery","From Senior to Staff")),
  @("XII","Interview Synthesis and Master Revision","Convert knowledge into concise, accurate explanations and cross-topic reasoning rather than rote memorization.",@("How to Build a Senior-Level Answer","Contrast Tables That Prevent Category Errors","End-to-End Failure Tracing","Guarantee Reasoning","Senior and Staff Interview Drills","Final Concept Map"))
)

$manifest = [Collections.Generic.List[string]]::new()
$manifest.Add("# Assembly order. Paths are relative to the repository root.")
$manifest.Add("book/front-matter/title.md")
$manifest.Add("book/front-matter/visual-notation.md")

for ($partIndex = 0; $partIndex -lt $parts.Count; $partIndex++) {
  $partNumber = "$($partIndex + 1)".PadLeft(2, "0")
  $partDir = Join-Path $chapterRoot "part-$partNumber"
  New-Item -ItemType Directory -Force -Path $partDir | Out-Null

  $partPath = Join-Path $partDir "_part.md"
  if (-not (Test-Path -LiteralPath $partPath)) {
    @(
      "# Part $($parts[$partIndex][0]) - $($parts[$partIndex][1]) {.part}",
      "",
      $parts[$partIndex][2],
      ""
    ) | Set-Content -LiteralPath $partPath -Encoding UTF8
  }
  $manifest.Add("book/chapters/part-$partNumber/_part.md")

  $chapters = $parts[$partIndex][3]
  for ($chapterIndex = 0; $chapterIndex -lt $chapters.Count; $chapterIndex++) {
    $chapterNumber = "$($chapterIndex + 1)".PadLeft(2, "0")
    $title = $chapters[$chapterIndex]
    $slug = ($title.ToLowerInvariant() -replace "[^a-z0-9]+", "-").Trim("-")
    if ($slug.Length -gt 54) { $slug = $slug.Substring(0, 54).TrimEnd("-") }
    $fileName = "chapter-$chapterNumber-$slug.md"
    $chapterPath = Join-Path $partDir $fileName
    if (-not (Test-Path -LiteralPath $chapterPath)) {
      @(
        "## $($partIndex + 1).$($chapterIndex + 1) - $title {#chapter-$partNumber-$chapterNumber}",
        "",
        "<!-- STEP 2 DRAFT STATUS: PLANNED -->",
        ""
      ) | Set-Content -LiteralPath $chapterPath -Encoding UTF8
    }
    $manifest.Add("book/chapters/part-$partNumber/$fileName")
  }
}

$manifest.Add("book/front-matter/glossary.md")
$manifest.Add("book/front-matter/revision-sheet.md")
$manifest | Set-Content -LiteralPath (Join-Path $root "book\manifest.txt") -Encoding UTF8

Write-Host "Scaffolded $($parts.Count) parts and $(($parts | ForEach-Object { $_[3].Count } | Measure-Object -Sum).Sum) chapters."

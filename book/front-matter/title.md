::: {.book-cover}

<div class="cover-kicker">THE SENIOR ENGINEERING EDITION</div>

<div class="cover-title">Systems<br>from First Principles</div>

<div class="cover-subtitle">The Senior and Staff Engineer's Handbook of Software Engineering Fundamentals</div>

<div class="cover-rule"></div>

<div class="cover-promise">Mechanisms • Guarantees • Failure • Evidence • Judgment</div>

:::

# About This Book {.unnumbered}

This handbook rebuilds transferable software-engineering fundamentals from first
principles. It is written for experienced backend engineers preparing to explain
systems clearly, diagnose failures, and make senior- or staff-level tradeoffs.

The book excludes coding-puzzle techniques and framework-specific recipes. It
concentrates on the mechanisms underneath languages and products: how data is
represented, how work executes, where guarantees end, how systems fail, and how
engineers obtain evidence. When behavior depends on a product or version, the
text labels that dependency instead of presenting it as universal.

## How to read it {.unnumbered}

The parts build on one another, but experienced readers can enter at any chapter.
Each non-trivial idea is developed through its purpose, mechanism, tradeoffs,
production failures, evidence, and interview lens.

## The staff-level reading method {.unnumbered}

For every mechanism, ask seven questions: What problem does it solve? What is
the unit of state? Where is the authority? Which ordering or durability promise
exists? Under which failures does it hold? How is overload controlled? Which
observation would prove or disprove the explanation? This method connects the
CPU cache, a database transaction, a Kafka partition, and a multi-region system
without pretending they are the same abstraction.

::: {.interview-tip}
**Interview Tip**

What separates a precise senior answer from a definition-only answer.
:::

::: {.scenario}
**Real-World Scenario**

A generic, explicitly hypothetical situation used to connect mechanisms.
:::

::: {.gotcha}
**Gotcha**

A tempting but inaccurate shortcut, hidden assumption, or failure mode.
:::

::: {.key-terms}
**Key Terms**

The small vocabulary needed to reason about the surrounding section.
:::

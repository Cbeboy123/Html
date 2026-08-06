## 6.2 - The Relational Model {#chapter-06-02}

The relational model represents information as relations of tuples over defined
attributes. SQL products implement this model with practical extensions and
multiset behavior, so relational theory and SQL syntax are related but not
identical.

A **candidate key** uniquely identifies a tuple. A primary key is the candidate
chosen as the main identifier. A foreign key constrains values to reference an
allowed key, preserving referential integrity. A unique constraint expresses a
business invariant rather than merely accelerating lookup.

`NULL` represents missing/unknown/not-applicable information under SQL’s
three-valued logic. Comparisons involving NULL do not behave like comparisons
with an ordinary value; use the language’s explicit null predicates. Products
can differ in details such as uniqueness and null handling.

Constraints keep correctness close to shared data. Application validation
improves user feedback, but concurrent writers can both pass a prior read.
Database constraints arbitrate at the write boundary.

Logical design describes facts and relationships. Physical design chooses
indexes, partitioning, storage layout, and access paths. One logical model can
support several physical designs without changing its meaning.

::: {.gotcha}
**Gotcha**

Surrogate keys provide stable identity but do not replace natural uniqueness
constraints. Without the latter, duplicate business facts remain possible.
:::

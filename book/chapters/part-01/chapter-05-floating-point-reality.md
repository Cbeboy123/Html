## 1.5 — Floating-Point Reality {#chapter-01-05}

An invoice total becomes `29.999999...` after several calculations. The computer
did not forget arithmetic. The program asked a finite binary format to represent
values that may not have a finite binary expansion.

**Floating-point** represents a number using a sign, a significand, and an
exponent, conceptually similar to scientific notation. IEEE 754 defines widely
used formats and arithmetic behavior. A finite format can represent only a
finite set of values, so most real numbers must be rounded to a nearby
representable value.

Binary floating point represents powers-of-two fractions naturally. Many
ordinary decimal fractions repeat in base 2, just as one third repeats in base
10. The stored value can be close to the decimal input without being exactly
equal to it.

| Need | Typical choice | Main caution |
|---|---|---|
| Scientific measurement | Binary floating point | Model tolerance and accumulated error |
| Approximate statistics | Binary floating point | Operation order can affect rounding |
| Money with fixed minor units | Scaled integer or decimal type | Currency rules and scale still need definition |
| Arbitrary precision | Big integer or decimal library | More CPU and memory; precision still needs a policy |

Special values such as positive and negative infinity and **NaN** (“not a
number”) support defined exceptional computations. NaN has unusual comparison
behavior and must not be treated as an ordinary value.

Error can accumulate through repeated addition, subtraction of nearly equal
values, and mixing values with very different magnitudes. Reordering operations
may change the final rounding even when real-number algebra says the expressions
are equivalent. Parallel reductions can therefore produce small result
differences without a data race.

::: {.gotcha}
**Gotcha**

There is no universal equality tolerance. A useful tolerance depends on scale,
units, error propagation, and the business rule. Sometimes exact equality is
correct, such as comparing a value with a lossless copy of itself.
:::

Production diagnosis starts with the representation and operations, not the
formatted display. Log enough significant information to reproduce the path,
verify conversions at API and database boundaries, and define rounding at the
business boundary where it has meaning.

::: {.interview-tip}
**Interview Tip**

Explain finite representation rather than saying “floats are inaccurate.”
Choose a representation from the domain’s required operations and exactness.
:::


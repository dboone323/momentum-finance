# Xcode 26.3 Intelligence: MomentumFinance Hints

## Architecture Oversight

The primary logic is in `Sources/MomentumFinanceCore/Services`.

## Intelligence Integration

- **Index Priority**: `BudgetAgent.swift` is the core agentic service.
- **Model Root**: Look at `BudgetModels.swift` for financial data structures.

## Optimization Hints

- Strict concurrency is enabled for all finance core targets.
- Agents should leverage the `BaseAgent` protocol from `SharedKit`.

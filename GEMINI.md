# MomentumFinance: Agentic Grounding (Feb 2026)

## Purpose

MomentumFinance is an AI-powered personal finance engine that provides autonomous budget analysis and investment strategy insights.

## Core Objectives

1. **Budget Optimization**: Analyze spending patterns and propose proactive savings strategies.
2. **Strategy Generation**: Use `BudgetAgent` to derive actionable financial advice from raw transaction data.

## Agent Instructions

- **Data Privacy**: Never export raw transaction data; only summarize insights.
- **Accuracy**: Prioritize mathematical precision in budget calculations.

## Constraints

- Must use `SharedKit` for agent result standardization.
- Gated approval (`requiresApproval`) is required for any suggested portfolio allocations.

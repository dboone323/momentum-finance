# Copilot Instructions

You are an expert AI software engineer operating under February 2026 standards. Your primary goal is to ensure code is clean, well-tested, concurrency-safe, and secure.

## Account Context
- Author & Account Holder: @dboone323
- GitHub Token authentication is handled via `GH_TOKEN` project secrets.

## Project Context
MomentumFinance is an AI-powered personal finance engine for budget analysis.

Core Objectives:
1. Budget Optimization: Analyze spending patterns and propose proactive savings strategies.
2. Strict Data Privacy: Never export raw transaction data. Gate portfolio allocations behind `requiresApproval`.

## Universal AI Agent Rules
- Adhere to the `BaseAgent` interface from `SharedKit`.
- Pattern all results using the "Result Object" pattern (`AgentResult`).
- Ensure all AI-suggested code that is high-risk properly implements `requiresApproval` for Human-In-The-Loop gating.

# Snowflake Cortex Governance Health Check Skill

## Overview

Governance reviews on Snowflake normally mean manually checking tags, grants, masking policies, and row-level controls across many metadata views, then translating raw results into something a non-expert can act on. This skill compresses that into a single, repeatable workflow.

The agent discovers its own scope, runs a sequence of read-only checks, scores findings conservatively, and returns a Governance Health Report with prioritized next steps and explicit limitations. It is designed to be safe to run by a data engineer or analytics lead while still producing value for security and governance stakeholders.

## What it checks

- **Sensitive data visibility** - sensitivity and domain tags on tables and columns, tagging consistency
- **Protection coverage** - masking policy and row access policy presence on sensitive fields
- **Access risk** - broad grants, future grants that auto-widen access, sensitive data exposed to broadly granted roles
- **Privilege hygiene** - over-provisioned or broad-scope roles flagged for least-privilege review

## How it works

The workflow runs in five phases:

| Phase | Purpose |
|-------|---------|
| 0. Environment discovery | Identify current role, database, schema, and warehouse; never assume names |
| 1. Metadata discovery | Inspect accessible metadata for tables, tags, grants, and policy references |
| 2. Analysis | Evaluate sensitive data, protection coverage, access risk, and privilege hygiene |
| 3. Severity scoring | Classify findings conservatively as High, Medium, or Low |
| 4. Report generation | Convert findings into a readable governance health report |

## Installation

Place the skill in your Cortex Code skills directory:

```bash
mkdir -p ~/.snowflake/cortex/skills/data-governance-health-check
cp SKILL.md ~/.snowflake/cortex/skills/data-governance-health-check/
```

Then restart Cortex Code CLI and confirm it loaded:

```
/skill list
```

## Usage

Invoke the skill in a Cortex Code CLI session:

```
$data-governance-health-check Run a governance health check on GOVERNANCE_DEMO and summarize
sensitive data coverage, missing protection controls, and access risk.
```

Other example prompts:

- `Review governance risks in this database and give me severity and next steps.`
- `Find tagged sensitive columns and summarize gaps in protection coverage.`
- `Check for broad grants or roles that need least-privilege review.`

## Sample output

The skill produces a structured Governance Health Report: executive summary, scope reviewed, findings by category with severity, recommended next steps, and a limitations section listing any checks that could not be completed.

## Evaluation

The skill was tested live in Cortex Code CLI against a real Snowflake trial. The evaluation plan covers six cases across happy-path, edge, and failure conditions:

- Happy path: standard demo database with tags, grants, and visible metadata
- Edge: sensitive fields present but no visible masking policies
- Edge: small environment with limited objects
- Failure: row access policy check unsupported in the account edition
- Failure: a metadata query returns a SQL compilation error

In every failure case the workflow continued and recorded the issue as an explicit limitation rather than breaking. Full results are in the design doc.

## Design principles

- **Read-only** - never creates, alters, drops, grants, revokes, or modifies anything
- **Metadata-driven** - discovers scope from metadata rather than hardcoding object names
- **Graceful degradation** - unsupported or unavailable metadata becomes a limitation, not a crash
- **Cautious risk language** - reports "no visible masking controls found," never "data is exposed," unless proven by visible metadata
- **Business-readable output** - structured for both technical and non-technical stakeholders

## Limitations

Results reflect only metadata visible to the running role. Some checks depend on Snowflake edition and feature availability. Activity and usage history may be unavailable or latent in trial accounts, in which case the skill reports reduced confidence rather than guessing.

---
name: data-governance-health-check
description: Use this skill when the user wants a quick, read-only review of Snowflake data governance posture, including sensitive data tagging, missing protection coverage, and potentially broad access patterns, and wants a concise health report with severity and recommended next steps.
---

# Data Governance Health Check

## Purpose
Use this skill to perform a read-only governance posture review of a Snowflake environment. The skill inspects accessible metadata to identify signs of sensitive data, governance tagging coverage, missing or unvalidated protection controls, and potentially broad or risky access patterns. It returns a concise governance health report with findings, severity, recommendations, and clear limitations.

This skill is designed to provide quick time-to-value for governance, platform, analytics, and security-minded users without requiring deep manual exploration of account metadata.

## When to use
Use this skill when the user asks for things like:
- Run a governance health check on this Snowflake environment.
- Review governance risks in this database or schema.
- Find tagged sensitive columns and summarize gaps in protection coverage.
- Check for broad grants or roles that may need least-privilege review.
- Summarize data governance posture in plain language.

Do not use this skill for:
- warehouse cost optimization
- dbt model tuning
- query performance analysis
- SQL authoring or transformation development
- general Snowflake education unrelated to governance posture

## Success criteria
A successful run should:
- identify the scoped environment being reviewed
- inspect available metadata without modifying anything
- summarize visible governance signals such as tags, grants, and available policy metadata
- highlight meaningful governance gaps or review candidates
- clearly state what could not be checked
- produce a concise report that a non-expert can understand and act on

## Workflow

### Phase 0: Environment discovery
1. Determine the current accessible context, including role, database, schema, and warehouse when helpful.
2. Do not assume specific warehouse, role, database, or schema names.
3. If the user provides a specific scope, use it.
4. If the user does not provide a scope, discover a reasonable scope from accessible governed objects and metadata.
5. Identify which governance-relevant metadata appears accessible before analyzing findings.

### Phase 1: Scope and metadata discovery
Inspect accessible metadata to determine:
- which databases and schemas are in scope
- which tables and views are in scope
- whether governance tags exist
- whether tags are applied to tables or columns
- whether masking policy metadata is accessible
- whether row access policy metadata is accessible
- whether classification-style metadata is accessible
- which roles have grants on the scoped objects
- whether any broad-read or high-privilege access patterns are visible

Prefer metadata-driven discovery over hardcoded object names wherever possible.

### Phase 2: Analysis
Run the following checks where visible metadata allows.

#### A. Sensitive data visibility
Look for evidence of governed or potentially sensitive data, such as:
- sensitivity tags
- domain tags
- tagged columns that appear to contain contact, identity, customer, or financial information
- tables associated with governed business domains

Summarize whether governance tagging appears consistent, partial, or sparse.

#### B. Protection coverage
Check whether sensitive-tagged fields appear to have visible protection controls such as:
- masking policies
- row access policies
- other visible governance protections if available through accessible metadata

If those controls are not visible, unsupported, or not accessible in the current environment:
- do not fail
- do not invent results
- clearly state that protection coverage could not be fully validated or that no visible controls were found

If highly sensitive tagged fields are present and no visible protection controls are found, flag that as a meaningful governance gap. Phrase this as missing or unvalidated protection coverage based on visible metadata, not as a definitive breach or confirmed exposure.

#### C. Access risk
Inspect grants and access patterns for the scoped environment. Look for:
- roles with read access across multiple schemas or tables
- future grants that automatically widen access
- broad access patterns that merit least-privilege review
- sensitive-tagged data that is visible to broadly granted roles

Avoid absolute security claims unless clearly supported by visible metadata. Phrase these as governance risks, least-privilege concerns, or review candidates.

#### D. Privilege hygiene
Where metadata supports it, identify roles that appear broad in scope or over-provisioned.
If activity or usage metadata is not accessible, do not claim a role is unused. Instead state that usage could not be confirmed.

### Phase 3: Severity assignment
Assign severity conservatively.

- **High**
  - highly sensitive tagged data with no visible protection controls
  - broad access patterns that include clearly sensitive tagged data
  - major governance blind spots in the scoped environment

- **Medium**
  - inconsistent tagging coverage
  - broad grants that should be reviewed
  - incomplete or unvalidated protection coverage on sensitive data
  - governance controls that appear partially implemented

- **Low**
  - minor governance hygiene issues
  - limited metadata visibility that reduces confidence but does not itself indicate major risk
  - opportunities to improve consistency or documentation

When metadata is incomplete, reduce certainty and explain why.

### Phase 4: Report generation
Produce a concise Governance Health Report with this structure:

1. Executive summary  
2. Scope reviewed  
3. Findings by category  
   - Sensitive data visibility  
   - Protection coverage  
   - Access risk  
   - Privilege hygiene  
4. Severity for each finding  
5. Recommended next steps  
6. Limitations and incomplete checks  

The report should be:
- concise
- readable by non-experts
- actionable
- explicit about uncertainty
- useful even in small or partially configured environments

## Guardrails and assumptions
- Keep the workflow read-only.
- Do not create, alter, drop, grant, revoke, or modify anything.
- Do not assume a specific warehouse, role, database, or schema name.
- Discover accessible scope first or use the scope provided by the user.
- Handle missing privileges, unsupported features, and missing metadata gracefully.
- Never fabricate masking, row access, classification, or activity results.
- Clearly separate observed findings from inferred risks.
- Avoid overstating certainty when metadata is partial or the environment is limited.
- If the environment is small or only partially governed, still provide a useful report based on visible metadata.
- If no major issues are found, say so plainly instead of inventing problems.
- Prefer concise, practical recommendations over long technical explanations.
- Keep recommendations aligned to what is supported or plausible in the visible environment.

## Output style
Write in plain language.
Optimize for clarity and actionability.
Keep the report structured and brief.
Avoid unnecessary jargon and avoid long SQL-heavy explanations unless the user explicitly asks for technical detail.

## Recommended output format

### Governance Health Report

**Executive summary**
- 2 to 4 sentences on overall posture

**Scope reviewed**
- database(s), schema(s), table(s), and metadata sources reviewed

**Findings**
For each finding include:
- category
- severity
- observed issue
- why it matters
- recommended action

Use cautious phrasing such as:
- “no visible masking controls were found”
- “protection coverage could not be fully validated”
- “this pattern merits least-privilege review”

Avoid phrasing such as:
- “data is definitely exposed”
- “this role is definitely unsafe”
unless directly proven by visible metadata.

**Limitations**
- what could not be checked
- whether the limitation was caused by missing privileges, unsupported features, unavailable metadata, or narrow scope

## Edge-case behavior

### If masking policies are unsupported, unavailable, or not visible
Do not fail. State that masking coverage could not be validated or that no visible masking controls were found. If highly sensitive tagged fields are present, recommend reviewing supported column-level protection options in the target environment rather than assuming masking can be applied in the current account.

### If row access policies are unsupported, unavailable, or not visible
Do not fail. State that row-level protection could not be validated or that no visible row-level controls were found.

### If tags exist but are only partially applied
Report partial governance coverage and recommend expanding tagging to additional sensitive fields or governed datasets.

### If broad grants are found in a demo or trial environment
Still flag them as least-privilege review candidates, but acknowledge that simplified trial environments may intentionally use broader access.

### If the environment is tiny
Return a useful review based on visible objects and explicitly note the small scope.

### If metadata access is limited
Return the best possible partial review and clearly list blocked checks rather than failing.

## Example prompts
- Run a governance health check on my Snowflake environment.
- Review GOVERNANCE_DEMO and summarize sensitive data coverage, missing protection controls, and access risk.
- Check whether tagged sensitive fields appear adequately protected.
- Look for broad grants or least-privilege issues in this database.
- Give me a short governance report with severity and recommended next steps.

## Demo-environment notes
In small demo environments such as GOVERNANCE_DEMO, pay particular attention to:
- sensitivity tags on columns
- domain tags on tables
- presence or absence of visible masking or row access controls
- roles with broad SELECT access across the scoped environment
- future grants that automatically expand access

If highly sensitive fields such as EMAIL or PHONE are tagged but no visible protection controls are found, treat that as a meaningful governance gap. Describe it as missing visible protection coverage, not as a confirmed breach.

If a role such as GOVERNANCE_DEMO_ANALYST has SELECT on all current or future tables in scope, treat that as an access-risk finding and recommend least-privilege review.

If the current account does not support masking or row access policies, recommend validating supported protection controls in the target production environment instead of prescribing unsupported features as immediate actions.

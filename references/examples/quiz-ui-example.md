# TF-{X} Generic UI Form — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: ui
> Developer articulation: 5 questions / 18 turns
> Linked TF spec: tfs.md#TF-{X}

## Q1: Form submission behavior

When user fills form fields F1, F2, F3 and clicks Submit, what exactly happens?
(Validation order / error display / success indicator / redirect / data persistence)

**Developer answer (final, locked after 3 rounds)**:
- Validation order: F1 → F2 → F3 (top to bottom). Stop at first invalid.
- Error display: red border on invalid field + tooltip below "Field {name}: {reason}"
- F1 valid = required + length 1-50
- F2 valid = email format (RFC 5322 simplified)
- F3 valid = numeric + range 18-100
- All valid → POST /submit, button shows spinner
- 200 response → green checkmark + "Saved" toast 3s + redirect to /list
- 4xx response → red banner with response.message
- 5xx response → red banner "서버 오류, 잠시 후 다시 시도"
- Timeout 10s → red banner "응답 지연, 다시 시도"

**Critique log**:
- Round 1 [Vagueness]: "valid" → criteria? / "spinner" → which? / "redirect" → where?
- Round 2 [Specificity]: F2 email format / F3 range / toast duration
- Round 3 [Completeness]: 4xx vs 5xx vs timeout error handling

**Test spec (auto-derived)**:
- E2E: fill F1="" → submit → expect F1 red border + tooltip "Field F1: required"
- E2E: fill F1="A", F2="invalid" → submit → expect F2 red border
- E2E: fill all valid → submit → expect spinner → 200 → toast "Saved" → /list
- E2E: server returns 503 → expect red banner with default text
- E2E: server delays > 10s → expect timeout banner

## Q2: Field state persistence

If user fills form, navigates away (back button), returns — should fields persist?

**Developer answer**:
- Persist in browser sessionStorage on every keystroke
- Restore on page load if sessionStorage has entry < 1 hour old
- Clear sessionStorage on successful submit
- Clear button = explicit clear all + clear storage

**Critique log**:
- Round 1 [Specificity]: "persist" → where? localStorage vs sessionStorage / "navigate away" → all routes or just back button?
- Round 2 [Completeness]: TTL on storage / explicit clear

**Test spec**:
- Unit: typing → sessionStorage updated within 100ms
- E2E: fill → back → forward → expect fields restored
- E2E: fill → submit success → back → expect fields empty

## Q3: Accessibility (a11y)

What a11y standards must form meet?

**Developer answer**:
- WCAG AA contrast (4.5:1)
- All inputs have <label> associated
- Error messages = aria-live="polite"
- Tab order = visual order
- Submit button = aria-disabled when validating

## Q4: Mobile/responsive

Layout below viewport 600px wide?

**Developer answer**:
- Single column stack
- Inputs full-width minus 16px padding
- Submit button = full-width
- Error tooltips = inline below field (not absolute positioned — would cut off)

## Q5: Loading states

Initial form load (data fetched async)?

**Developer answer**:
- Skeleton placeholder for form fields (3 grey rectangles)
- Disabled submit until data loaded
- Loading > 5s = "Loading..." text + spinner
- Load failure = error banner "Form load failed, refresh to retry"

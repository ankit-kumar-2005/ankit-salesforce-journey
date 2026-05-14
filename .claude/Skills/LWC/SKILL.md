---
name: lwc
description: Expert LWC development for Salesforce. Use this skill whenever the user mentions LWC, Lightning Web Components, component, .html/.js/.css/.xml files in a Salesforce project, wire adapters, @api/@track/@wire decorators, custom events, slots, or asks to build, review, or debug any front-end Salesforce UI. Also trigger for Aura-to-LWC migration questions and any component that calls Apex from the UI layer.
---

# Salesforce Lightning Web Components (LWC)

## Required Context to Gather First

Ask for or infer:
- component purpose and target surface
- data source: LDS, Apex, GraphQL, LMS, or external system via Apex
- whether the user needs tests
- whether the component must run in Flow, App Builder, Experience Cloud, or dashboard contexts
- accessibility and styling expectations

---

## 1. Component Generation

### File Structure

Every component lives in a folder matching the component name (camelCase for folder, kebab-case in markup):

```
force-app/main/default/lwc/myComponent/
  myComponent.html          # required
  myComponent.js            # required
  myComponent.js-meta.xml   # required — missing this breaks deployment
  myComponent.css           # optional
  myComponent.test.js       # optional but expected for PRs
```

The `js-meta.xml` must declare valid targets or the component will not deploy:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>59.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__RecordPage</target>
        <target>lightning__AppPage</target>
        <target>lightning__HomePage</target>
    </targets>
</LightningComponentBundle>
```

### JS Decorators

| Decorator | Purpose | Notes |
|-----------|---------|-------|
| `@api` | Public property or method | Reactive; parents set it; never mutate directly in child |
| `@track` | Deep reactivity | Only needed for nested object/array mutations in modern LWC (API v39+); plain properties are already reactive |
| `@wire` | Wire service binding | Declarative; re-runs when params change |

```js
import { LightningElement, api, track, wire } from 'lwc';
import getContacts from '@salesforce/apex/ContactController.getContacts';

export default class MyComponent extends LightningElement {
    @api recordId;          // passed from parent or record page
    // @track not needed for a plain object — LWC tracks it automatically
    data = {};

    @wire(getContacts, { accountId: '$recordId' })
    wiredContacts({ data, error }) {
        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
}
```

### Calling Apex

**Use `@wire`** for data that loads automatically and should refresh when record changes.

**Use imperative calls** for user-triggered actions (button clicks, form submits):

```js
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecord from '@salesforce/apex/MyController.saveRecord';

async handleSave() {
    try {
        await saveRecord({ data: this.formData });
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Record saved.',
            variant: 'success'
        }));
    } catch (error) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: error.body?.message ?? 'An unexpected error occurred.',
            variant: 'error'
        }));
    }
}
```

### Lifecycle: Use `connectedCallback()`, Not `constructor()`

`constructor()` runs before the component is in the DOM. Avoid DOM access or property reads from `@api` there — they are not set yet.

```js
connectedCallback() {
    // safe to read @api values, query labels, initialize data loads
    this.loadData();
}
```

### Lightning Data Service (LDS) First

Prefer LDS components before writing custom Apex for standard CRUD:

- **Read:** `<lightning-record-view-form>` or `getRecord` wire adapter
- **Edit:** `<lightning-record-edit-form>` (handles validation, FLS, sharing automatically)
- **Create/Edit modal:** `<lightning-record-form>` for simple layouts
- **Custom UI + Apex:** only when LDS cannot meet the requirement (related lists, multi-object transactions, complex DML)

---

## 2. Events & Communication

### Child-to-Parent: CustomEvent

```js
// child
handleClick() {
    this.dispatchEvent(new CustomEvent('recordselect', {
        detail: { id: this.recordId },
        bubbles: true,    // propagates up the DOM tree
        composed: false   // false = stops at shadow boundary (preferred for LWC)
    }));
}
```

```html
<!-- parent -->
<c-child-component onrecordselect={handleRecordSelect}></c-child-component>
```

Use `composed: true` only when the event must cross shadow DOM boundaries (rare).

### Parent-to-Child: @api

```js
// child exposes a public method
@api
refreshData() {
    this.loadData();
}
```

```js
// parent calls it via ref
this.template.querySelector('c-child-component').refreshData();
```

Always use `this.template.querySelector` — never `document.querySelector`. LWC shadow DOM scopes selectors to the component tree.

### Cross-Component (Siblings): Lightning Message Service

LMS is the platform-supported replacement for the old pubsub pattern.

```js
// publisher
import { publish, MessageContext } from 'lightning/messageService';
import MY_CHANNEL from '@salesforce/messageChannel/MyChannel__c';

@wire(MessageContext) messageContext;

publishMessage() {
    publish(this.messageContext, MY_CHANNEL, { recordId: this.recordId });
}

// subscriber
import { subscribe, MessageContext } from 'lightning/messageService';

@wire(MessageContext) messageContext;
subscription = null;

connectedCallback() {
    this.subscription = subscribe(this.messageContext, MY_CHANNEL, (msg) => {
        this.handleMessage(msg);
    });
}
```

---

## 3. Code Review

### Performance

- Avoid `@wire` calls that return unbounded record sets — add server-side `LIMIT` and paginate with offset or cursor.
- Lazy-load heavy child components with conditional rendering (`lwc:if`) rather than `display:none` — hidden components still execute JS.
- Debounce input handlers that trigger wire param updates.

### Accessibility

- All interactive elements need `aria-label` or `aria-labelledby`.
- Use SLDS utility classes (`slds-visually-hidden` for screen-reader-only text) rather than custom CSS hacks.
- Test keyboard navigation — `<lightning-button>` handles this; raw `<div onclick>` does not.

### Security

- **Never use `innerHTML`** — direct XSS vector.
- Use `lwc:inner-html` only with content that has been sanitized server-side or via `DOMPurify`.
- Never log Apex response objects to console in production code — they may contain PII.
- Validate `@api` inputs before passing to Apex.

### Common Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| `@track` on every property "just in case" | Only use `@track` for nested mutation reactivity |
| Wire handler ignores `error` branch | Always handle both `data` and `error` branches; show error state in UI |
| No loading/error state in template | Add `lwc:if={isLoading}` spinner and `lwc:if={error}` error panel |
| Apex called in `constructor()` | Move to `connectedCallback()` |
| `document.querySelector` | Use `this.template.querySelector` |
| Mutating `@api` property directly in child | Clone the object; `@api` props flow down only |

---

## 4. Debugging

### Browser DevTools

- Open Chrome DevTools on a Lightning page. In the **Components** tab (Salesforce Lightning Inspector extension), browse the component tree, inspect `@api`/`@track` state, and replay events.
- Console errors prefixed with `[LWC error]` originate in the framework layer — note the component name in the stack trace.

### Common Runtime Errors

| Error | Cause | Fix |
|---|---|---|
| `Cannot read properties of undefined (reading 'fieldName')` | Wire data accessed before load | Guard with `lwc:if={data}` in template or null-check in JS |
| `this is not defined` inside a callback | Arrow function lost `this` context | Use arrow functions consistently or bind explicitly |
| `Error: [Cannot set property of read-only object]` | Mutating `@api` prop or wire result directly | Clone: `this.record = { ...this.wiredRecord.data }` |
| Component not visible in App Builder | `js-meta.xml` missing target or `isExposed` is false | Add correct `<target>` entries, set `<isExposed>true</isExposed>` |
| Deployment error: `Unknown property` | API version mismatch or typo in meta.xml | Match `apiVersion` to org's supported release |

### VS Code Setup

- Install **Salesforce Extension Pack** (official bundle: Apex, LWC, CLI integration).
- Use `sf lightning dev component` (LWC Dev Server) for rapid local iteration without deploying to org.
- Enable ESLint with `@salesforce/eslint-plugin-lwc` — catches decorator misuse and accessibility issues before review.

### Jest Testing

```js
// myComponent.test.js
import { createElement } from 'lwc';
import MyComponent from 'c/myComponent';
import getContacts from '@salesforce/apex/ContactController.getContacts';

jest.mock('@salesforce/apex/ContactController.getContacts', () => ({
    default: jest.fn()
}), { virtual: true });

describe('c-my-component', () => {
    afterEach(() => { while (document.body.firstChild) document.body.removeChild(document.body.firstChild); });

    it('renders contacts on wire success', async () => {
        getContacts.mockResolvedValue([{ Id: '001', Name: 'Test' }]);
        const el = createElement('c-my-component', { is: MyComponent });
        document.body.appendChild(el);
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('.contact-name')).not.toBeNull();
    });
});
```

---

## 5. Output Format

### Component Generation

Provide every file as a separate, labeled code block:

```
**myComponent.html**
**myComponent.js**
**myComponent.js-meta.xml**
**myComponent.css** (if needed)
```

Include a brief note on any non-obvious design choice (why LDS over Apex, why `bubbles: false`, etc.).

## Reference Map

### Start here
- [references/component-patterns.md](references/component-patterns.md)
- [references/slds-design-guide.md](references/slds-design-guide.md)
- [references/lwc-best-practices.md](references/lwc-best-practices.md)
- [references/scoring-and-testing.md](references/scoring-and-testing.md)
- [references/jest-testing.md](references/jest-testing.md)

### Accessibility / performance / state
- [references/accessibility-guide.md](references/accessibility-guide.md)
- [references/performance-guide.md](references/performance-guide.md)
- [references/state-management.md](references/state-management.md)
- [references/template-anti-patterns.md](references/template-anti-patterns.md)

### Integration / advanced features
- [references/lms-guide.md](references/lms-guide.md)
- [references/flow-integration-guide.md](references/flow-integration-guide.md)
- [references/advanced-features.md](references/advanced-features.md)
- [references/async-notification-patterns.md](references/async-notification-patterns.md)
- [references/triangle-pattern.md](references/triangle-pattern.md)
- [assets/](assets/)

## Cross-Skill Integration

| Need | Delegate to | Reason |
|---|---|---|
| Apex controller or service | [apex](../apex/SKILL.md) | backend logic |
| embed in Flow screens | [flow](../flow/SKILL.md) | declarative orchestration |
| deploy component bundle | [deploy](../deploy/SKILL.md) | org rollout |
| create metadata like message channels | [metadata](../metadata/SKILL.md) | supporting metadata |

### Code Review

Group findings by severity:

- **Critical** — security or data integrity risk (XSS, unchecked wire error crashing page)
- **Major** — performance or correctness issue
- **Minor** — style, accessibility, or maintainability

Format each finding as:
```
[SEVERITY] file.js:42 — description of issue
Recommendation: specific fix
```

### Debugging

Structure responses as:

1. **Root cause** — one sentence
2. **Reproduction path** — how to confirm
3. **Fix** — code snippet or config change
4. **Prevention** — lint rule or pattern to avoid recurrence
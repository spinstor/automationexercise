# AutomationExercise — Robot Framework Test Automation

A professional-grade, maintainable Robot Framework test suite for the practice
site **[https://automationexercise.com](https://automationexercise.com/)**.

The framework follows industry-standard test automation layering so that any
QA engineer can extend it quickly without duplicating effort:

```
┌─────────────────────────────────────────────────────────────────┐
│  tests/            High-level, readable test cases only          │
├─────────────────────────────────────────────────────────────────┤
│  workflows/        Business flows (register, purchase, ...)      │
├─────────────────────────────────────────────────────────────────┤
│  page_keywords/    Actions per page  (Login, Cart, ...)          │
├─────────────────────────────────────────────────────────────────┤
│  locators/         Element definitions ONLY (no logic)           │
├─────────────────────────────────────────────────────────────────┤
│  common/           Browser session, navigation, generic helpers  │
├─────────────────────────────────────────────────────────────────┤
│  api/              RequestsLibrary keywords + JSON assertions    │
├─────────────────────────────────────────────────────────────────┤
│  data/             Test data & unique-data factory               │
└─────────────────────────────────────────────────────────────────┘
```

Tests never hold locators or page logic; they only orchestrate **workflow**
keywords. This gives:

- **Reusability** — every layer is a small, single-responsibility resource.
- **Maintainability** — the locator that changes is fixed in exactly ONE file.
- **Consistency** — one browser profile, one timeout policy, one data factory.

---

## Requirements

- Python 3.10+ (`3.14` validated)
- Google Chrome / Firefox / Edge (a matching WebDriver is auto-managed by Selenium)

## Installation

```sh
cd automationexercise
python -m pip install -r requirements.txt
```

> The `webdrivermanager`-style auto-download is handled by Selenium Manager
> (bundled with Selenium 4.10+), so no manual driver installation is needed.

## Running the tests

From the repository root:

```sh
# Everything (UI + API)
bin\run_all.cmd

# Smoke only (fast feedback)
bin\run_smoke.cmd

# A single suite
bin\run_suite.cmd tests\auth\login.robot

# API only
bin\run_suite.cmd tests\api
```

Reports and logs are written to `output\` (`log.html`, `report.html`).

### Common runtime options

Override any default without touching code:

| Option                              | Effect                              |
| ----------------------------------- | ----------------------------------- |
| `--variable BROWSER:headlesschrome` | Run UI in headless mode             |
| `--variable HEADLESS:true`          | Headless, keeping `BROWSER` as-is   |
| `--variable HEADLESS:false`         | Headed — default, no flag needed    |
| `--variable BROWSER:firefox`        | Run UI in Firefox                   |
| `--variable BASE_URL:https://<env>` | Point at a different environment    |
| `--variable TEST_PASSWORD:Secret1!` | Supply a different password         |
| `--tag regression`                  | Run regression-tagged tests only    |
| `--exclude smoke`                   | Skip smoke tests                    |

Headless vs headed is a pure runtime choice — no code change needed:

```sh
bin\run_suite.cmd tests\auth\login.robot                    # headed (default)
bin\run_suite.cmd tests\auth\login.robot --variable HEADLESS:true
bin\run_suite.cmd tests\auth\login.robot --variable BROWSER:headlesschrome
```

Examples:

```sh
robot --outputdir output --variable BROWSER:headlesschrome tests
robot --outputdir output --tag smoke tests\api
```

All defaults live in one place: `resources\common\variables.robot`.

## MongoDB-driven credentials

The `tests\auth\mongo_credentials.robot` suite logs in with credentials stored
in MongoDB instead of the generated ones. The framework reads the first
**enabled** document from the `robot_auth.users` collection and turns it into
`${LOGIN_EMAIL}`, `${LOGIN_PASSWORD}` and `${LOGIN_NAME}`.

### Install and start MongoDB

Download the **MSI** for Windows from the official MongoDB Community Server
page at https://www.mongodb.com/try/download/community and run the installer
(default install is fine). Do **not** use the portable ZIP on this machine —
its `mongod.exe` fails to start (loader error `0xC0000139`) even with the
latest VC++ redistributable.

After install, start the server (or install MongoDB as a Windows service via
the installer and start it in Services). Confirm it answers:

```sh
mongosh --eval "db.runCommand({ ping: 1 })"
```

### Seed a login account

```sh
python scripts\seed_mongo.py seed --email sofia@example.com --password 'Passw0rd!123' --name Sofia
```

Other subcommands: `list`, `enable --email <e>`, `disable --email <e>`,
`delete --email <e>`. Only documents with `"enabled": true` are used.

### Run the Mongo-driven test

```sh
bin\run_mongo.cmd tests\auth\mongo_credentials.robot
```

The account is provisioned on the site through the API (idempotent), so the
credentials you seed are exactly the ones that log in.

### Connection settings

Environment variables override the defaults:

| Variable           | Default                     |
| ------------------ | --------------------------- |
| `MONGO_URI`        | `mongodb://localhost:27017/` |
| `MONGO_DB`         | `robot_auth`                |
| `MONGO_COLLECTION` | `users`                     |

Example pointing at a remote server with auth:

```sh
set MONGO_URI=mongodb://user:pass@db.example.com:27017/?authSource=admin
bin\run_mongo.cmd tests\auth\mongo_credentials.robot
```

## Project structure

```
automationexercise/
├── bin/                        # Convenience run scripts (.cmd)
├── config/                     # Robot variablefiles
│   └── mongo_login.py          # Reads ${LOGIN_*} variables from MongoDB
├── scripts/                    # Standalone helpers
│   └── seed_mongo.py           # Seed/list/enable/disable/delete Mongo logins
├── output/                     # Generated logs & reports (git-ignored)
├── resources/
│   ├── common/                 # Session, timeouts, navigation, helpers
│   │   ├── browser_management.robot
│   │   ├── common_keywords.robot
│   │   ├── navigation.robot
│   │   └── variables.robot     # <-- all default configuration
│   ├── locators/               # Page-object locators, one file per page
│   │   ├── auth_locators.robot
│   │   ├── cart_locators.robot
│   │   ├── checkout_locators.robot
│   │   ├── contact_locators.robot
│   │   ├── home_locators.robot
│   │   └── product_locators.robot
│   ├── page_keywords/          # Actions for each page
│   ├── workflows/              # Business flows
│   │   ├── auth_flows.robot
│   │   ├── cart_flows.robot
│   │   └── checkout_flows.robot
│   ├── api/                    # API testing keywords & assertions
│   │   └── api_keywords.robot
│   └── data/                   # Static dataset + unique-data factory
│       ├── data_manager.py     # Unique emails/names/cards for repeatable runs
│       └── test_data.robot
└── tests/                      # Actual test cases, grouped by domain
    ├── home/
    ├── auth/
    │   ├── login.robot
    │   └── mongo_credentials.robot
    ├── products/
    ├── cart/
    ├── checkout/
    ├── contact/
    └── api/
```

## How the layering works (extending the framework)

**1 — Find the locator.** Each page has one locator file:
`resources\locators\<page>_locators.robot`. Never hard-code a selector in a
test or keyword.

**2 — Add the action.** Page behaviour belongs in
`resources\page_keywords\<page>_page.robot`. One keyword = one small action
("Login With Credentials", "Add Product To Cart").

**3 — Compose the flow.** Cross-page sequences (register → buy → confirm) live
in `resources\workflows\*.robot`.

**4 — Write the test.** Tests in `tests\<area>\*.robot` only call workflow
keywords and assert outcomes.

Example — adding a new test in `tests\cart\cart_operations.robot`:

```robot
Add First Product Shows The Price
    Add Product To Cart From Home
    Open Cart And Verify Product Added    ${VALID_PRODUCT}
```

## Testing strategy

| Concern                        | Approach                                            |
| ------------------------------ | --------------------------------------------------- |
| **Repeatability**              | `DataManager` factory generates unique emails/cards |
| **UI setup speed**             | Account setup is done through the **API** when only |
|                                | login behaviour is under test                       |
| **Flake-resistance**           | Shared wait/retry helpers: `Wait Until Element Is   |
|                                | Visible And Click`, `Input Text If Visible`, ...    |
| **Failure diagnostics**        | Every suite auto-captures a screenshot on failure   |
| **Tag-based selection**        | `smoke`, `regression`, `UI`, `API`, plus domain tags|
| **CI friendliness**            | API tests need no browser; UI supports headless     |

## CI / organization notes

- API tests (`tests\api\api_smoke.robot`) can run on any agent with Python +
  network — no browser required.
- To drive values from your CI secret store, pass them with
  `--variable TEST_PASSWORD:%SECRET%` (no code change required).
- `robotframework-tidy` is pinned in `requirements.txt` for formatting;
  use `robotidy --check resources tests` in a pre-merge check if desired.

## Troubleshooting

| Symptom                                  | Fix                                            |
| ---------------------------------------- | ---------------------------------------------- |
| "WebDriver ... not found"                | Update Selenium: `python -m pip install -U Selenium` |
| Browser tests too slow locally           | Use `BROWSER:headlesschrome` (easier in CI)    |
| Login/registration tests conflict        | They auto-generate unique emails — never reuse |
| A locator breaks after site change       | Fix it in the corresponding `*_locators.robot` |
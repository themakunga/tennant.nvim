# Security / Seguridad

Report vulnerabilities privately using GitHub's **Security → Report a vulnerability**
for this repository. Do not publish exploit details or credentials in an issue.
Supported code is the latest main commit and current develop prerelease.

Reports are reviewed by @themakunga. There is no guaranteed response-time SLA.

Checks cover Lua lint, generic dangerous-execution patterns, regression payloads,
secret scanning of staged changes and Git history, workflow security and pinned
actions/binaries. Generic Semgrep rules are not full Lua dataflow analysis. CodeQL
does not support Lua. CI does not prove absence of vulnerabilities or validate
speech pronunciation. No blanket exclusions are permitted; exceptions need owner
review, a narrow scope, rationale and a regression check where applicable.

Untrusted PR tests receive no secrets or write permissions. Publication is restricted
to validated develop pushes. The policy workflow only reads GitHub metadata and
never executes PR contents. Scan artifacts expire after 30 days; secrets are redacted.

## Español

Reporta vulnerabilidades en privado mediante **Security → Report a vulnerability**.
No publiques credenciales ni detalles de explotación en issues. @themakunga revisa
los reportes; no se promete un plazo de respuesta. Se soportan main actual y la
pre-release vigente de develop.

Los controles incluyen secretos, workflows, patrones peligrosos y pruebas de
regresión. Las reglas genéricas de Lua no son análisis completo del flujo de datos.
Toda excepción exige revisión del propietario, alcance concreto y justificación.

The policy workflow has one narrow zizmor exception for `pull_request_target`: it
uses only API metadata, never checks out code, and passes no PR text to a shell.
Owner review is required for changes to this trust boundary.

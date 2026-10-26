# platform-apex-logs-debug - Reference Examples, Patterns & Troubleshooting

## Gotchas

| Pitfall | Resolution |
|---------|------------|
| Log truncated at 2 MB | Reduce debug levels (e.g., `ApexCode: INFO`, `ApexProfiling: FINE`) and re-capture |
| Same issue appears as both SOQL and CPU problem | Fix SOQL-in-loop first — it typically drives the CPU spike as a secondary effect |
| No logs appear after trace flag is set | Verify the trace flag `ExpirationDate` is in the future and the correct user is traced |
| Async context changes limit values | CPU limit is 60,000 ms async vs 10,000 ms sync — check transaction type before flagging limits |
| Stack trace points to framework line, not user code | Walk up the call stack past trigger handlers to find the originating user code |

---

---

## Score Guide

| Score | Meaning |
|---|---|
| 90+ | Expert analysis with strong fix guidance |
| 80–89 | Good analysis with minor gaps |
| 70–79 | Acceptable but may miss secondary issues |
| 60–69 | Partial diagnosis only |
| < 60 | Incomplete analysis |

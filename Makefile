invariant-Dex:
	forge test --match-path test/Dex.invariants.t.sol -vvv

invariant-call-summary:
	forge test  -m invariant_callSummary -vv
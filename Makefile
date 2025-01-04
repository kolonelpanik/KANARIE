# Include .env file and export its variables
-include .env
export

# Default target
.DEFAULT_GOAL := help

# Dependencies
update:
	forge update

# Build & Test
test:
	forge test -vvv --no-match-contract DeploymentsGasLimits --fork-url ${MAINNET_RPC_URL}

test-contract:
	forge test --match-contract ${filter} -vvv --fork-url ${MAINNET_RPC_URL}

test-watch:
	forge test --watch -vvv --no-match-contract DeploymentsGasLimits --fork-url ${MAINNET_RPC_URL}

# Coverage
coverage-base:
	forge coverage --report lcov --no-match-coverage "(scripts|tests|deployments|mocks)" --fork-url ${MAINNET_RPC_URL}

coverage-clean:
	lcov --rc derive_function_end_line=0 --remove ./lcov.info -o ./lcov.info.p \
		'lib/aave-v3-origin/src/contracts/extensions/v3-config-engine/*' \
		'lib/aave-v3-origin/src/contracts/treasury/*' \
		'lib/aave-v3-origin/src/contracts/dependencies/openzeppelin/ReentrancyGuard.sol' \
		'lib/aave-v3-origin/src/contracts/helpers/UiIncentiveDataProviderV3.sol' \
		'lib/aave-v3-origin/src/contracts/helpers/UiPoolDataProviderV3.sol' \
		'lib/aave-v3-origin/src/contracts/helpers/WalletBalanceProvider.sol' \
		'lib/aave-v3-origin/src/contracts/dependencies/*' \
		'lib/aave-v3-origin/src/contracts/helpers/AaveProtocolDataProvider.sol' \
		'lib/aave-v3-origin/src/contracts/protocol/libraries/configuration/*' \
		'lib/aave-v3-origin/src/contracts/protocol/libraries/logic/GenericLogic.sol' \
		'lib/aave-v3-origin/src/contracts/protocol/libraries/logic/ReserveLogic.sol'

coverage-report:
	genhtml ./lcov.info.p -o report --branch-coverage --rc derive_function_end_line=0 --parallel

coverage-badge:
	coverage=$$(awk -F '[<>]' '/headerCovTableEntryHi/{print $3}' ./report/index.html | sed 's/[^0-9.]//g' | head -n 1); \
	wget -O ./report/coverage.svg "https://img.shields.io/badge/coverage-$${coverage}%25-brightgreen"

coverage: coverage-base coverage-clean coverage-report coverage-badge

# Gas Reports
gas-reports:
	forge test --mp 'tests/gas/*.t.sol' --isolate --fork-url ${MAINNET_RPC_URL}

# Utilities
download:
	cast etherscan-source --chain ${chain} -d src/etherscan/${chain}_${address} ${address}

git-diff:
	@mkdir -p diffs
	@npx prettier ${before} ${after} --write
	@printf '%s\n%s\n%s\n' "\`\`\`diff" "$$(git diff --no-index --ignore-space-at-eol ${before} ${after})" "\`\`\`" > diffs/${out}.md

# Deployment
deploy-libs-one:
	forge script scripts/misc/LibraryPreCompileOne.sol --rpc-url ${chain} --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --slow --broadcast

deploy-libs-two:
	forge script scripts/misc/LibraryPreCompileTwo.sol --rpc-url ${chain} --ledger --mnemonic-indexes ${MNEMONIC_INDEX} --sender ${LEDGER_SENDER} --verify --slow --broadcast

deploy-libs:
	make deploy-libs-one chain=${chain}
	npx catapulta-verify -b broadcast/LibraryPreCompileOne.sol/${chainId}/run-latest.json
	make deploy-libs-two chain=${chain}
	npx catapulta-verify -b broadcast/LibraryPreCompileTwo.sol/${chainId}/run-latest.json

# Help
help:
	@echo "Makefile Targets:"
	@echo "  update          Update dependencies"
	@echo "  test            Run all tests"
	@echo "  test-contract   Run tests matching specific contract"
	@echo "  test-watch      Watch tests for changes"
	@echo "  coverage        Generate code coverage report"
	@echo "  gas-reports     Generate gas usage reports"
	@echo "  download        Download contract sources from Etherscan"
	@echo "  git-diff        Generate a git diff with Prettier formatting"
	@echo "  deploy-libs     Deploy library contracts"

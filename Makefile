include .env 

.PHONY: push, interaction

push:
	git add .
	git commit -m "fulfillrandomwords tests"
	git push origin master

interaction-sepolia:
	forge script script/Interactions.s.sol:$(INTERACTION) --private-key $(PRIVATE_KEY_METAMASK) --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) --broadcast

test-fork:
	forge test --mt testPerformUpkeepRunsWhenCheckUpkeepIsTrue --fork-url $(RPC_URL_SEPOLIA_ALCHEMY)  -vvvv

install :; forge install Cyfrin/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install transmissions11/solmate@v6 --no-commit

deploy:
	forge script script/LotteryDeploy.s.sol:LotteryDeploy --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) --private-key $(PRIVATE_KEY_METAMASK) --broadcast --verify --etherscan-api-key $(API_KEY_ETHERSCAN) -vvvv

debug:
	forge test --debug testInitializesInOpenState
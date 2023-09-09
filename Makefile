include .env 

.PHONY: push, interaction

push:
	git add .
	git commit -m "added interactions - create, fund subscription (sepolia + anvil)"
	git push origin master

interaction:
	forge script script/Interactions.s.sol:$(INTERACTION) --private-key $(PRIVATE_KEY_METAMASK) --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) --broadcast

install :; forge install Cyfrin/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install transmissions11/solmate@v6 --no-commit

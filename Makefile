.PHONY: push

push:
	git add .
	git commit -m "pick up a random winner, send contract full balance, reset lottery"
	git push origin master


install :; forge install Cyfrin/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install transmissions11/solmate@v6 --no-commit

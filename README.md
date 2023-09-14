# Smart Lottery

Uses smart contracts, Chainlink VRF and Upkeep to builld a smart contract lottery system where users can buy tickets and after a fixed amount of time, the smart system chooses the winner in a verifiable manner. All the money that was deposited on the contract is then sent to the winner's address.

Using Foundry, Chainlink VRF, Chainlink Automation, Solmate, Solidity 0.8.18, Cyfrin devop.

Built with the inspiration of Patrick's Collins tutorial.

## Project Structure
### imports
1. foundry-rs/forge-std@v1.5.3  
2. transmissions11/solmate@v6
3. smartcontractkit/chainlink-brownie-contracts@0.6.1
    - VRFCoordinatorV2Interface (random number)
    - VRFConsumerBaseV2 (random number)
    - AutomationCompatibleInterface  (automation)
4. Cyfrin/foundry-devops@0.0.11

### contracts (src)
1. Lottery
1. constructor is a VRFConsumer that needs a VRFCoordinator (proper to every chain)
2. buyTicket function
    - it's the only user interaction
3. checkupkeep (Automation)
    - checks if it's time to call the Upkeep
4. performUpkeep (Automation + Randomness)
    - the contract (Coordinator) requestRandomwords
5. fullfillRandomWords (Randomness)
    - gives back the randomWords
    - uses it to calculate the random winner
    - it sends the contract's balance to the winner


### test

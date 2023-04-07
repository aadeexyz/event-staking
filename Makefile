.PHONY: all test clean

# Default target
all: clean remove install update build

# Clean the cache
clean:
	forge clean

# Remove the modules
remove:
	rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install the modules
install:
	forge install foundry-rs/forge-std && forge install transmissions11/solmate

# Update the modules
update:
	forge update

# Build the project
build:
	forge build

# Test the project
test:
	forge test
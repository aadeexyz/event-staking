.PHONY: all test clean

all: clean remove install update build

clean:
	forge clean

remove:
	rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install:
	forge install foundry-rs/forge-std && forge install transmissions11/solmate

update:
	forge update

build:
	forge build

test:
	forge test
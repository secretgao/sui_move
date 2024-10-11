
buil 合约
sui move build  --skip-fetch-latest-git-deps

发布合约
sui client publish --gas-budget 800000000 --skip-dependency-verification --skip-fetch-latest-git-deps

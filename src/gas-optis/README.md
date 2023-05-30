# Smart Contract Gas Optimizations Challenges

This repository is designed to test your gas optimization skills as a Solidity developer. The challenges presented here are intended to evaluate your understanding of contract bottlenecks and your ability to optimize them effectively. Each exercise focuses on a specific optimization technique, allowing you to demonstrate your knowledge and expertise.

The objective of these challenges is not to encourage participants to try random strategies or rewrite the entire contract in assembly. Instead, we aim to assess your understanding of contract bottlenecks and your ability to identify and implement optimizations without resorting to low-level techniques. While some exercises may require advanced knowledge, most of the gas targets can be achieved using Solidity's high-level constructs.

## Prerequisites

Have [Foundry](https://book.getfoundry.sh/getting-started/installation) installed.

## Instructions

**Explore the challenges:** Inside the repository, you will find several challenge folders, each containing three files:

- `Common.sol`: This file provides useful contracts and interfaces, including the interface that must be implemented by the contract you'll optimize.
- `Reference.sol`: The reference contract represents the original implementation with potentially inefficient gas usage. The goal is to reproduce its behavior in a more optimized way. Note that not all functions in the contract need to be optimized.
- `Optimized.sol`: This is the contract that you'll optimize. You should make modifications to this contract only. Ensure that the modified contract still implements the required interface from `Common.sol` to avoid compilation errors.

**Run the tests:** To run the tests and verify the correctness and gas consumption of your optimized contract, use the following command:

```shell
forge test
```

This command will execute all the tests in the repository.

**Focus on specific tests (optional):** If you want to focus on a specific exercise, you can use the `--match-contract` flag followed by the exercise name. For example, to run the tests of an exercise named `Example`, use the following command:

```shell
forge test --match-contract TestExample
```

This command will execute only the specified exercise, allowing you to focus on one challenge at a time.

**Review the test results:** After running the tests, you will see logs showing the reference gas usage, target gas usage, the record, and the current gas usage of your optimized contract. The goal is to minimize the gas usage of your optimized contract to reach or surpass the target gas usage.

<i><b>Note:</b> If you have any questions or suggestions, please feel free to open an issue or reach out to the repository maintainer. However, we kindly request that you refrain from publishing the solution publicly, including in issues or pull requests. Instead, we encourage you to directly contact the repository maintainer for further discussion.</i>

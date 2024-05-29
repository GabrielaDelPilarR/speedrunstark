use starknet::{ContractAddress, contract_address_const, felt, assert_eq};
use snforge_std::{declare, ContractClassTrait};
use openzeppelin::utils::serde::SerializedAppend;

use contracts::Staker::{
    IStaker, IStakerTrait
};

use openzeppelin::tests::utils::constants::{
    ZERO, OWNER, SPENDER, RECIPIENT, NAME, SYMBOL, DECIMALS, SUPPLY, VALUE
};

fn deploy_staker_contract() -> ContractAddress {
    let contract = declare("Staker");
    let mut calldata = array![];
    calldata.append_serde(OWNER());
    contract.deploy(@calldata).unwrap()
}

#[test]
fn test_stake_functionality() {
    let contract_address = deploy_staker_contract();
    let staker = IStaker { contract_address };

    let initial_balance = staker.balances(contract_address);
    let stake_amount: u256 = 1000;

    // Simulate staking
    staker.stake(stake_amount);

    let expected_balance = initial_balance + stake_amount;
    let actual_balance = staker.balances(contract_address);

    assert_eq!(actual_balance, expected_balance, "Balance should be increased by the stake amount");
}

#[test]
fn test_withdraw_functionality() {
    let contract_address = deploy_staker_contract();
    let staker = IStaker { contract_address };

    let stake_amount: u256 = 1000;
    staker.stake(stake_amount);

    // Assuming the contract is open for withdrawal
    staker.withdraw();

    let expected_balance: u256 = 0;
    let actual_balance = staker.balances(contract_address);

    assert_eq!(actual_balance, expected_balance, "Balance should be zero after withdrawal");
}

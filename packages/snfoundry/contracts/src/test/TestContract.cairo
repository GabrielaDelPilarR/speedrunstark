use contracts::Staker::IStakerDispatcherTrait;
use contracts::Staker::IStakerDispatcher;
use starknet::{ContractAddress, contract_address_const, get_block_timestamp};
use snforge_std::{declare, ContractClassTrait, start_warp, CheatTarget};
use openzeppelin::utils::serde::SerializedAppend;

use openzeppelin::tests::utils::constants::{
    ZERO, OWNER, SPENDER, RECIPIENT, NAME, SYMBOL, DECIMALS, SUPPLY, VALUE
};

fn deploy_staker_contract() -> ContractAddress {
    let external = declare("ExampleExternalContract").unwrap();
    let (external_address, _) = external.deploy(@array![]).unwrap();

    let contract = declare("Staker").unwrap();
    let mut calldata = array![];
    calldata.append_serde(external_address);
    let (contract_address, _) = contract.deploy(@calldata).unwrap();
    contract_address
}

#[test]
fn test_mint_item() {
    let contract_address = deploy_staker_contract();
    // let owner = OWNER();
   
    let staker = IStakerDispatcher { contract_address };
    
    let initial_balance = staker.balances(contract_address);
    let stake_amount: u256 = 1_000_000_000_000_000_000;

    // Simulate staking
    staker.stake(stake_amount);

    let expected_balance = initial_balance + stake_amount;
    let actual_balance = staker.balances(contract_address);

    assert_eq!(actual_balance, expected_balance, "Balance should be increased by the stake amount");
}

#[test]
fn test_withdraw_functionality() {
    let contract_address = deploy_staker_contract();
    let staker = IStakerDispatcher { contract_address };

    let stake_amount: u256 = 1_000_000_000_000_000_000;
    staker.stake(stake_amount);

    let time = staker.time_left();
    // miss get current blocktime
    start_warp(CheatTarget::All, get_block_timestamp() + time);

    // Assuming the contract is open for withdrawal
    staker.withdraw();

    let expected_balance: u256 = 0;
    let actual_balance = staker.balances(contract_address);

    assert_eq!(actual_balance, expected_balance, "Balance should be zero after withdrawal");
}

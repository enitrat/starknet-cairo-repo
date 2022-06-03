%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.lib.IPool import IPool
from contracts.lib.types.DataTypes import DataTypes
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from starkware.cairo.common.uint256 import Uint256
from contracts.lib.IAtoken import IAToken
from starkware.cairo.common.math import assert_not_equal, assert_not_zero

const PRANK_USER = 123

@external
func test_suite{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local aToken) = deploy_contract()
    init_reserve(pool, test_token, aToken)
    supply(pool, test_token, aToken)
    withdraw(pool, test_token, aToken)
    borrow(pool, test_token, aToken)
    repay(pool, test_token, aToken)
    return ()
end

func deploy_contract{syscall_ptr : felt*, range_check_ptr}() -> (
    contract_address : felt, test_token_address : felt, aToken_address : felt
):
    alloc_locals
    local contract_address : felt
    local test_token_address : felt
    local aToken_address : felt
    %{ stop_prank_callable = start_prank(ids.PRANK_USER) %}  # Prank contract deployer

    # We deploy contract and put its address into a local variable. Second argument is calldata array
    %{
        BASE_PATH = "../cairo-pools/"
        ids.contract_address = deploy_contract(BASE_PATH+"contracts/src/Pool.cairo", [0]).contract_address

        ids.test_token_address = deploy_contract(BASE_PATH+"contracts/src/ERC20.cairo", [1415934836,5526356,18,1000,0,ids.PRANK_USER]).contract_address 

        ids.aToken_address = deploy_contract(BASE_PATH+"contracts/src/AToken.cairo", [418027762548,1632916308,18,0,0,ids.contract_address,ids.contract_address,ids.test_token_address]).contract_address
    %}
    return (contract_address, test_token_address, aToken_address)
end

func init_reserve{syscall_ptr : felt*, range_check_ptr}(
    pool : felt, test_token : felt, aToken : felt
):
    IPool.init_reserve(pool, test_token, aToken)
    let (reserve) = IPool.get_reserve(pool, test_token)
    assert reserve.aToken_address = aToken
    return ()
end

func supply{syscall_ptr : felt*, range_check_ptr}(pool : felt, test_token : felt, aToken : felt):
    # Prank test_token so that inside test_token, caller() is PRANK_USER
    %{ stop_prank_token = start_prank(ids.PRANK_USER, target_contract_address=ids.test_token) %}
    IERC20.approve(test_token, pool, Uint256(100, 0))

    # Stop previous prank (because we use test_token) as parameter
    # Start prank on pool so that in pool contract, pool caller is PRANK_USER
    %{
        stop_prank_pool = start_prank(ids.PRANK_USER, target_contract_address=ids.pool)
        stop_prank_token()
    %}
    IPool.supply(pool, test_token, Uint256(100, 0), PRANK_USER, 0)
    %{ stop_prank_pool() %}

    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(900, 0)

    let (user_aTokens) = IAToken.balanceOf(aToken, PRANK_USER)
    assert user_aTokens = Uint256(100, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(100, 0)
    return ()
end

func withdraw{syscall_ptr : felt*, range_check_ptr}(pool : felt, test_token : felt, aToken : felt):
    # Prank pool so that inside the contract, caller() is PRANK_USER
    %{ stop_prank_pool= start_prank(ids.PRANK_USER, target_contract_address=ids.pool) %}
    IPool.withdraw(pool, test_token, Uint256(50, 0), PRANK_USER)

    %{ stop_prank_pool() %}

    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(950, 0)

    let (user_aTokens) = IAToken.balanceOf(aToken, PRANK_USER)
    assert user_aTokens = Uint256(50, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(50, 0)

    return ()
end

func borrow{syscall_ptr : felt*, range_check_ptr}(pool : felt, test_token : felt, aToken : felt):
    %{ stop_prank_pool= start_prank(ids.PRANK_USER, target_contract_address=ids.pool) %}
    IPool.borrow(pool, test_token, Uint256(10, 0), 0, 0, PRANK_USER)
    %{ stop_prank_pool() %}

    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(960, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(40, 0)

    return ()
end

func repay{syscall_ptr : felt*, range_check_ptr}(pool : felt, test_token : felt, aToken : felt):
    # Prank test_token so that inside test_token, caller() is PRANK_USER
    %{ stop_prank_token = start_prank(ids.PRANK_USER, target_contract_address=ids.test_token) %}
    IERC20.approve(test_token, pool, Uint256(10, 0))

    # Stop previous prank (because we use test_token) as parameter
    # Start prank on pool so that in pool contract, pool caller is PRANK_USER
    %{
        stop_prank_pool = start_prank(ids.PRANK_USER, target_contract_address=ids.pool)
        stop_prank_token()
    %}
    IPool.repay(pool, test_token, Uint256(10, 0), 0, PRANK_USER)

    %{ stop_prank_pool() %}

    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(950, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(50, 0)

    return ()
end

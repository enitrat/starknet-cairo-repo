%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem, assert_nn
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_check, uint256_sub
from contracts.lib.DataTypes import ReserveData

from contracts.PoolStorage import (
    _reserves,
    _reservesList,
    _reservesCount,
    user_balance,
    get_reserve,
    get_balance,
)

from contracts.lib.ReserveLogic import ReserveLogic

@external
func supply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, onBehalfOf : felt
):
    ReserveLogic._executeSupply(asset, amount, onBehalfOf)
    return ()
end

@external
func withdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, amount : Uint256, to : felt
):
    ReserveLogic._executeWithdraw(asset, amount, to)
    return ()
end

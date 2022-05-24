%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem, assert_nn
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_check,
    uint256_sub,
    uint256_lt,
)
from contracts.lib.DataTypes import ReserveData
from openzeppelin.security.safemath import SafeUint256

from contracts.PoolStorage import (
    _reserves,
    _reservesList,
    _reservesCount,
    user_balance,
    get_reserve,
    get_balance,
)

namespace ReserveLogic:
    func _executeSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt, amount : Uint256, onBehalfOf : felt
    ):
        alloc_locals
        # amount must be valid
        uint256_check(amount)
        let (prev_reserve) = _reserves.read(asset)  # parenthesis required to unpack function result
        # Adding uint256 with the associated function from OZ that doesnt support overflows.
        let (local new_reserve_supply) = SafeUint256.add(prev_reserve.supply, amount)
        let new_reserve = ReserveData(
            prev_reserve.id, prev_reserve.aTokenAddress, new_reserve_supply
        )

        # New reserve has another supply
        _reserves.write(asset, value=new_reserve)

        # Increase user balance
        let (prev_balance) = user_balance.read(onBehalfOf, asset)
        let (local new_balance) = SafeUint256.add(prev_balance, amount)
        user_balance.write(onBehalfOf, asset, value=new_balance)
        return ()
    end

    func _executeWithdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt, amount : Uint256, to : felt
    ):
        alloc_locals
        # amount must be valid
        uint256_check(amount)

        let (caller_address) = get_caller_address()

        # current pool supply & user balances
        let (prev_balance) = user_balance.read(caller_address, asset)
        let (prev_reserve) = _reserves.read(asset)  # parenthesis required to unpack function result

        # Revert if amounts exceed balance/reserve
        with_attr error_message("ReserveLogic: transfer amount exceeds reserve"):
            let (new_reserve_supply : Uint256) = SafeUint256.sub_le(prev_reserve.supply, amount)
        end

        with_attr error_message("ReserveLogic: transfer amount exceeds balance"):
            let (new_user_balance : Uint256) = SafeUint256.sub_le(prev_balance, amount)
        end
        # Decrease user balance
        user_balance.write(caller_address, asset, value=new_user_balance)

        # Decrease reserve
        let new_reserve = ReserveData(
            prev_reserve.id, prev_reserve.aTokenAddress, new_reserve_supply
        )
        _reserves.write(asset, value=new_reserve)

        return ()
    end
end

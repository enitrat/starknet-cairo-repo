%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from DataTypes import ReserveData
from src.PoolStorage import (
    _reserves,
    _reservesList,
    _reservesCount,
    user_balance,
    get_reserve,
    get_balance,
)
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_check,
    uint256_sub,
    uint256_lt,
)

namespace ReserveLogic:
    func init{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve : ReserveData, aTokenAddress : felt
    ) -> (reserve : ReserveData):
        # Verify reserve was not priorly initialized
        with_attr error_message("Reserve already initialized for {asset}"):
            assert reserve.aTokenAddress = 0
        end

        # Write aTokenAddress in reserve
        let new_reserve = ReserveData(reserve.id, aTokenAddress, Uint256(0, 0))

        # TODO add other params such as liq index, debt tokens addresses...
        return (new_reserve)
    end
end

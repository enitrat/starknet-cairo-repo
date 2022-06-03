%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.lib.types.DataTypes import DataTypes
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_check,
    uint256_sub,
    uint256_lt,
)

namespace ReserveLogic:
    func init{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        reserve : DataTypes.ReserveData, aToken_address : felt
    ) -> (reserve : DataTypes.ReserveData):
        # Verify reserve was not priorly initialized
        with_attr error_message("Reserve already initialized for {asset}"):
            assert reserve.aToken_address = 0
        end

        # Write aToken_address in reserve
        let new_reserve = DataTypes.ReserveData(reserve.id, aToken_address)

        # TODO add other params such as liq index, debt tokens addresses...
        return (new_reserve)
    end
end

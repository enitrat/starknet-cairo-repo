%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.lib.DataTypes import ReserveData, BorrowParams
from contracts.src.PoolStorage import (
    _reserves,
)

namespace BorrowLogic:
    func executeBorrow(params : BorrowParams):
        let (reserve) = _reserves.read(params.asset)
        

    end
end

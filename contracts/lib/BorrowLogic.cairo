%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.lib.DataTypes import ReserveData, ExecuteBorrowParams, ExecuteRepayParams
from contracts.src.PoolStorage import _reserves
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from contracts.lib.IAToken import IAToken

namespace BorrowLogic:
    func execute_borrow{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        params : ExecuteBorrowParams
    ):
        let (reserve) = _reserves.read(params.asset)

        # TODO Borrow validation

        # Transfer tokens to borrower
        IAToken.transferUnderlyingTo(
            contract_address=reserve.aTokenAddress, target=params.onBehalfOf, amount=params.amount
        )

        # TODO Borrower debt
        return ()
    end

    func execute_repay{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        params : ExecuteRepayParams
    ):
        let (reserve) = _reserves.read(params.asset)
        let (caller) = get_caller_address()
        # User needs to approve first
        IERC20.transferFrom(
            contract_address=params.asset,
            sender=caller,
            recipient=reserve.aTokenAddress,
            amount=params.amount,
        )
        return ()
    end
end

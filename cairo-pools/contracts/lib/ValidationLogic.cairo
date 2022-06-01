%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from contracts.lib.DataTypes import ReserveData, ValidateBorrowParams, ValidateRepayParams
from contracts.lib.IAToken import IAToken
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from openzeppelin.security.safemath import SafeUint256
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_le, uint256_check
from starkware.cairo.common.math import assert_not_equal, assert_not_zero
from starkware.cairo.common.bool import TRUE, FALSE

namespace ValidationLogic:
    func validate_supply{range_check_ptr}(reserve : ReserveData, amount : Uint256):
        uint256_check(amount)

        with_attr error_message("Amount must be greater than 0"):
            let (is_zero) = uint256_eq(amount, Uint256(0, 0))
            assert is_zero = FALSE
        end
        # Revert if uninitialized reserve, doesn't exist in aave codebase ?
        with_attr error_message("Reserve not initialized"):
            assert_not_zero(reserve.aTokenAddress)
        end

        return ()
    end

    func validate_withdraw{syscall_ptr : felt*, range_check_ptr}(
        reserve : ReserveData, amount : Uint256, user : felt
    ):
        alloc_locals
        with_attr error_message("Amount must be greater than 0"):
            let (is_zero) = uint256_eq(amount, Uint256(0, 0))
            assert is_zero = FALSE
        end

        # Revert if uninitialized reserve, doesn't exist in aave codebase ?
        with_attr error_message("Reserve not initialized"):
            assert_not_zero(reserve.aTokenAddress)
        end

        # aToken balance of caller
        let (local caller_balance) = IAToken.balanceOf(reserve.aTokenAddress, user)

        # ## Validate withdraw ###

        with_attr error_message("Can't withdraw a null amount"):
            let (is_null) = uint256_eq(amount, Uint256(0, 0))
            assert is_null = FALSE
        end

        # Revert if withdrawing too much. Verify that amount<=balance
        with_attr error_message("Withdraw amount exceeds balance"):
            let (is_lt : felt) = uint256_le(amount, caller_balance)
            assert is_lt = TRUE
        end
        return ()
    end

    func validate_borrow(params : ValidateBorrowParams):
        # TODO CalculateUserData

        return ()
    end

    func validate_repay(params : ValidateRepayParams):
        return ()
    end
end

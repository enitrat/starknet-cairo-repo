%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import storage_read, storage_write, get_caller_address
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_check, uint256_eq, uint256_le
from contracts.lib.DataTypes import ReserveData
from openzeppelin.security.safemath import SafeUint256
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from contracts.lib.IAToken import IAToken
from contracts.lib.IMintable import IMintable
from contracts.lib.ValidationLogic import ValidationLogic

from starkware.cairo.common.bool import TRUE, FALSE

from contracts.src.PoolStorage import _reserves

namespace SupplyLogic:
    func _executeSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt, amount : Uint256, onBehalfOf : felt
    ):
        alloc_locals
        # amount must be valid
        let (reserve) = _reserves.read(asset)  # parenthesis required to unpack function result
        ValidationLogic.validate_supply(reserve, amount)
        
        let (caller) = get_caller_address()
        let (caller_balance) = IERC20.balanceOf(asset, caller)
        
        # Transfer underlying from caller to aTokenAddress
        IERC20.transferFrom(
            contract_address=asset, sender=caller, recipient=reserve.aTokenAddress, amount=amount
        )

        # Mint aToken to onBehalfOf address
        IAToken.mint(contract_address=reserve.aTokenAddress, to=onBehalfOf, amount=amount)

        return ()
    end

    func _executeWithdraw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        asset : felt, amount : Uint256, to : felt
    ):
        alloc_locals
        # amount must be valid
        uint256_check(amount)
        let (caller) = get_caller_address()
        let (reserve) = _reserves.read(asset)  # parenthesis required to unpack struct?
        ValidationLogic.validate_withdraw(reserve, amount, caller)

        # for now, simple implementation, burns coins and returns underlying
        IAToken.burn(
            contract_address=reserve.aTokenAddress, account=caller, recipient=to, amount=amount
        )

        return ()
    end
end

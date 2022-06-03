from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_check

namespace DataTypes:
    struct ReserveData:
        member id : Uint256
        member aToken_address : felt
    end

    struct ReserveCongigurationMap:
    end

    struct UserConfigurationMap:
        member data : Uint256
    end

    struct EModeCategory:
        member ltv : felt
        member liquidation_threshold : felt
        member liquidation_bonus : felt
        member price_source : felt
        member label : felt
    end

    struct InterestRateMode:
        member NONE : felt
        member STABLE : felt
        member VARIABLE : felt
    end

    struct ReserveCache:
        # can we do this in cairo?
    end

    struct ExecuteLiquidationCallParams:
        member reserves_count : Uint256
        member debt_to_cover : Uint256
        member collateral_asset : felt
        member debt_asset : felt
        member user : felt
        member receive_aToken : felt
        member price_oracle : felt
        member user_EMode_category : felt
        member price_oracle_sentinel : felt
    end

    struct ExecuteSupplyParams:
        member asset : felt
        member amount : Uint256
        member on_behalf_of : felt
        member referral_code : felt
    end

    struct ExecuteBorrowParams:
        member asset : felt
        member user : felt
        member on_behalf_of : felt
        member amount : Uint256
        member interest_rate_mode : felt  # Use struct as an enum here
        member referral_code : felt
        member release_underlying : felt
        member max_stable_rate_borrow_size_percent : felt
        member reserves_count : Uint256
        member oracle : felt
        member user_EMode_category : felt
        member price_oracle_sentinel : felt
    end

    struct ExecuteRepayParams:
        member asset : felt
        member amount : Uint256
        member interest_rate_mode : felt  # Use struct as an enum here
        member on_behalf_of : felt
        member use_aTokens : felt
    end

    struct ExecuteWithdrawParams:
        member asset : felt
        member amount : Uint256
        member to : felt
        member reserves_count : Uint256
        member oracle : felt
        member user_EMode_category : felt
    end

    struct ExecuteSetUserEModeParams:
        member reserves_count : Uint256
        member oracle : felt
        member category_id : felt
    end

    struct ValidateBorrowParams:
        member reserve : DataTypes.ReserveData
        member asset : felt
        member user_address : felt
        member amount : Uint256
        # Rest not necessary for now
    end

    struct ValidateRepayParams:
    end

    struct InitReserveParams:
        member asset : felt
        member aToken_address : felt
        member reserves_count : Uint256
    end
end

from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_check

struct ReserveData:
    member id : felt
    member aTokenAddress : felt
end

struct InitReserveParams:
    member asset : felt
    member aTokenAddress : felt
    member reserves_count : felt
end

struct ExecuteBorrowParams:
    member asset : felt
    member user : felt
    member onBehalfOf : felt
    member amount : Uint256
    # Rest not necessary for now
end

struct ExecuteRepayParams:
    member asset : felt
    member amount : Uint256
    member onBehalfOf : felt
    # Can't use aTokens yet
end

struct ValidateBorrowParams:
    member reserve : ReserveData
    member asset : felt
    member user_address : felt
    member amount : Uint256
    # Rest not necessary for now
end

struct ValidateRepayParams:
end


namespace ConfiguratorInputTypes:

    struct InitReserveInput:
        member aToken_impl:felt
        member stable_debt_token_impl:felt
        member variable_debt_token_impl:felt
        member underlying_asset_decimals:felt
        member interest_rate_stragegy_address:felt
        member underlying_asset:felt
        member treasury:felt
        member incentives_controller:felt
        member aToken_name:felt
        member aToken_symbol:felt
        member variable_debt_token_name:felt
        member variable_debt_token_symbol:felt
        member stable_debt_token_name:felt
        member stable_debt_token_symbol:felt
        member params:felt #VERIFY BYTES DATATYPE CONVERSION
    end
end

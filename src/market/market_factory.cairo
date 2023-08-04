//! Contract to create markets.

// *************************************************************************
//                                  IMPORTS
// *************************************************************************
use core::traits::Into;
use starknet::ContractAddress;

// *************************************************************************
//                  Interface of the `MarketFactory` contract.
// *************************************************************************
#[starknet::interface]
trait IMarketFactory<TContractState> {
    /// Create a new market.
    /// # Arguments
    /// * `index_token` - The token used as the index of the market.
    /// * `long_token` - The token used as the long side of the market.
    /// * `short_token` - The token used as the short side of the market.
    /// * `market_type` - The type of the market.
    fn create_market(
        ref self: TContractState,
        index_token: ContractAddress,
        long_token: ContractAddress,
        short_token: ContractAddress,
        market_type: felt252,
    );
}

#[starknet::contract]
mod MarketFactory {
    // *************************************************************************
    //                               IMPORTS
    // *************************************************************************
    use gojo::role::role;
    use gojo::role::role_store::{IRoleStoreDispatcher, IRoleStoreDispatcherTrait};
    use gojo::data::data_store::{IDataStoreDispatcher, IDataStoreDispatcherTrait};
    use gojo::market::market::{Market, UniqueIdMarketTrait};
    use starknet::{get_caller_address, ContractAddress, contract_address_const};

    // *************************************************************************
    //                              STORAGE
    // *************************************************************************
    #[storage]
    struct Storage {
        data_store: IDataStoreDispatcher,
        role_store: IRoleStoreDispatcher,
    }

    // *************************************************************************
    //                              CONSTRUCTOR
    // *************************************************************************
    #[constructor]
    fn constructor(
        ref self: ContractState,
        data_store_adress: ContractAddress,
        role_store_address: ContractAddress
    ) {
        self.data_store.write(IDataStoreDispatcher { contract_address: data_store_adress });
        self.role_store.write(IRoleStoreDispatcher { contract_address: role_store_address });
    }


    // *************************************************************************
    //                          EXTERNAL FUNCTIONS
    // *************************************************************************
    #[external(v0)]
    impl MarketFactory of super::IMarketFactory<ContractState> {
        /// Create a new market.
        /// # Arguments
        /// * `index_token` - The token used as the index of the market.
        /// * `long_token` - The token used as the long side of the market.
        /// * `short_token` - The token used as the short side of the market.
        /// * `market_type` - The type of the market.
        fn create_market(
            ref self: ContractState,
            index_token: ContractAddress,
            long_token: ContractAddress,
            short_token: ContractAddress,
            market_type: felt252,
        ) {
            // Get the caller address.
            let caller_address = get_caller_address();
            // TODO: Check that the caller has the MARKET_KEEPER role.

            // TODO: Deploy Market token and get address.
            // For now we mock the address.
            let market_token = contract_address_const::<'market_token'>();
            // Create the market.
            let market = Market { market_token, index_token, long_token, short_token, };
            // Compute the key of the market.
            let market_key = market.unique_id(market_type);
            // Add the market to the data store.
            self.data_store.read().set_market(market_key, market);
        }
    }
}
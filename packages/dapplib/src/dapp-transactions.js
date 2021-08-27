// 🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨
// ⚠️ THIS FILE IS AUTO-GENERATED WHEN packages/dapplib/interactions CHANGES
// DO **** NOT **** MODIFY CODE HERE AS IT WILL BE OVER-WRITTEN
// 🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨

const fcl = require("@onflow/fcl");

module.exports = class DappTransactions {

	static project_gimme_divisors() {
		return fcl.transaction`
				import RegistryDigitDivisors from 0x01cf0e2f2f715450
				
				transaction( number: Int) {
				
				  prepare(acct: AuthAccount) {
				    // save the Tenant resource to the account if it doesn't already exist
				    let divisors =  acct.borrow<&RegistryDigitDivisors.Tenant>(from: /storage/RegistryDigitDivisorsTenant)!
				    log( divisors.calculate( number ) )
				  }
				
				  execute {
				    log("Registered a new Tenant for RegistryDigitDivisors.")
				  }
				}
				
		`;
	}

	static registry_divisors_tenant() {
		return fcl.transaction`
				import RegistryDigitDivisors from 0x01cf0e2f2f715450
				import RegistryService from 0x01cf0e2f2f715450
				
				// This transaction allows any Tenant to receive a Tenant Resource from
				// RegistryDigitDivisors. It saves the resource to account storage.
				//
				// Note that this can only be called by someone who has already registered
				// with the RegistryService and received an AuthNFT.
				
				transaction() {
				
				  prepare(acct: AuthAccount) {
				    // save the Tenant resource to the account if it doesn't already exist
				    if acct.borrow<&RegistryDigitDivisors.Tenant>(from: /storage/RegistryDigitDivisorsTenant) == nil {
				      // borrow a reference to the AuthNFT in account storage
				      let authNFTRef = acct.borrow<&RegistryService.AuthNFT>(from: RegistryService.AuthStoragePath)
				                        ?? panic("Could not borrow the AuthNFT")
				      
				      // save the new Tenant resource from RegistryDigitDivisors to account storage
				      acct.save(<-RegistryDigitDivisors.instance(authNFT: authNFTRef), to: RegistryDigitDivisors.TenantStoragePath)
				
				      // link the Tenant resource to the public with ITenant restrictions
				      acct.link<&RegistryDigitDivisors.Tenant>(RegistryDigitDivisors.TenantPublicPath, target: RegistryDigitDivisors.TenantStoragePath)
				    }
				  }
				
				  execute {
				    log("Registered a new Tenant for RegistryDigitDivisors.")
				  }
				}
				
		`;
	}

	static registry_register_with_registry() {
		return fcl.transaction`
				import RegistryService from 0x01cf0e2f2f715450
				
				// Allows a Tenant to register with the RegistryService. It will
				// save an AuthNFT to account storage. Once an account
				// has an AuthNFT, they can then get Tenant Resources from any contract
				// in the Registry.
				//
				// Note that this only ever needs to be called once per Tenant
				
				transaction() {
				
				    prepare(acct: AuthAccount) {
				        // if this account doesn't already have an AuthNFT...
				        if acct.borrow<&RegistryService.AuthNFT>(from: RegistryService.AuthStoragePath) == nil {
				            // save a new AuthNFT to account storage
				            acct.save(<-RegistryService.register(), to: RegistryService.AuthStoragePath)  
				        }
				    }
				
				    execute {
				
				    }
				}
		`;
	}

}

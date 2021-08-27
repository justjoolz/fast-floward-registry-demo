import RegistryDigitDivisors from Registry.RegistryDigitDivisors
import RegistryService from Registry.RegistryService

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

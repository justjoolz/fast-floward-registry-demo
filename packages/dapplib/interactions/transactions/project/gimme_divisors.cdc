import RegistryDigitDivisors from Registry.RegistryDigitDivisors

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

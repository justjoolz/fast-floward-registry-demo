import RegistryInterface from Registry.RegistryInterface
import RegistryService from Registry.RegistryService

pub contract RegistryDigitDivisors: RegistryInterface { // presuming Registry is to be a prefix

    // Maps an address (of the customer/DappContract) to the amount
    // of tenants they have for a specific RegistryContract.
    access(contract) var clientTenants: {Address: UInt64}

    // Digits
    access(contract) var digits : [Digit]
    
    // Struct DigitShape - shape of an Digits divisors and weights etc.
    pub struct Digit {
        pub let id : UInt64
        pub let divisors : [UInt64]
        pub let sumOfDivisors : UInt64
        
        init(id: UInt64, divisors: [UInt64], sumOfDivisors: UInt64) {
            self.id = id
            self.divisors = divisors 
            self.sumOfDivisors = sumOfDivisors
        }
    }
   
    // Tenant
    //
    // Requirement that all conforming multitenant smart contracts have
    // to define a resource called Tenant to store all data and things
    // that would normally be saved to account storage in the contract's
    // init() function
    // 
    pub resource Tenant {    
        // returns a particular Digit's data
        pub fun getDigit(_ i: Int) : Digit{
            pre {
                i > 0 : "Must be above 0"
                // i <= self.Digits.length       : "Must be in range"            // here we enforce Digit is already calculated 
            }
            if i > RegistryDigitDivisors.digits.length {
                self.calculate(i-1)
            }
            return RegistryDigitDivisors.digits[i-1]
        }

        // returns all the Digits for script access
        pub fun getDigits() : [Digit] {
            return RegistryDigitDivisors.digits
        }

        // calculates Digit up to size n
        pub fun calculate(_ n: Int) : Digit {
            // start from number of Digits already calculated 
            var i = RegistryDigitDivisors.digits.length + 1 
            while i <= n {
                RegistryDigitDivisors.digits.append(self.calculateDigit( UInt64(i) ))
                i = i + 1
            }
            return RegistryDigitDivisors.digits[n-1]
        }

        // calculateDigit - Calculates (divisors, sum of divisors and weights for an integer #id)
        access(self) fun calculateDigit(_ n: UInt64) : Digit {

            pre {
                n > (0 as UInt64) : "Must be greater than 0"
            }

            let id = n
        
            // set initial divisor in array and inital sum
            var divisors = [ (1 as UInt64) ]
            var sumOfDivisors = (1 as UInt64)
            
            // start loop from 2nd term
            var i = (2 as UInt64)

            log(n)
                
            while Int(i) <= Int(id) { // Time Complexity : O(n)  can be improved to O(sqrt(n)) but would need Sqrt function :)
                
                // if it's divisible by i with no remainder
                if( UInt64(id) % UInt64(i) == (0 as UInt64) ) {
                    
                    // add to divisors array
                    divisors.append(i)

                    // create sum (used to caculate error)
                    sumOfDivisors = sumOfDivisors + i
                }
                i = i + (1 as UInt64)
            }

            let Digit = Digit( id: id, divisors: divisors, sumOfDivisors: sumOfDivisors)
            return Digit 
        }
        
        init() {
            // We save all data in the mutual 
        }
    }

    // instance
    // instance returns an Tenant resource.
    //
    pub fun instance(authNFT: &RegistryService.AuthNFT): @Tenant {
        let clientTenant = authNFT.owner!.address
        if let count = self.clientTenants[clientTenant] {
            self.clientTenants[clientTenant] = self.clientTenants[clientTenant]! + (1 as UInt64)
        } else {
            self.clientTenants[clientTenant] = (1 as UInt64)
        }

        return <-create Tenant()
    }

    // getTenants
    // getTenants returns clientTenants.
    //
    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
    }

    // Named Paths
    //
    pub let TenantStoragePath: StoragePath
    pub let TenantPublicPath: PublicPath


    init() {
        // Initialize clientTenants
        self.clientTenants = {}
        
        self.digits = []

        // Set Named paths
        self.TenantStoragePath = /storage/RegistryDigitDivisorsTenant
        self.TenantPublicPath = /public/RegistryDigitDivisorsTenant
    }
}
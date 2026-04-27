workspace "Microservices System" "Decoupled services with per-service databases." {

    model {
        webApp = person "Web Client" "User via browser."
        mobileApp = person "Mobile Client" "User via iOS/Android."
        thirdParty = person "External Partner" "API-based integration."

        system = softwareSystem "Streaming Platform" {
            gateway = container "API Gateway" "The entry point for all requests." "Spring Cloud Gateway" "Type:Gateway"

            # Service 1: Identity
            group "Identity Domain" {
                userDB = container "User Database" "Stores profile and auth data." "PostgreSQL" "Type:Database"
                userService = container "User Service" "Manages accounts." "Node.js" {
                    group "Account Modules" {
                        authModule = component "Auth Module" "Handles JWT and sessions." "Express" "Type:Module"
                        profileModule = component "Profile Module" "Manages user metadata." "Express" "Type:Module"
                    }
                }
            }

            # Service 2: Catalog
            group "Catalog Domain" {
                catalogDB = container "Catalog Database" "Stores content metadata." "MongoDB" "Type:Database"
                catalogService = container "Catalog Service" "Manages movie library." "Go" {
                    group "Search Modules" {
                        searchModule = component "Search Engine" "Full-text search logic." "Go" "Type:Module"
                        metadataModule = component "Metadata Manager" "Curates movie details." "Go" "Type:Module"
                    }
                }
            }

            # Service 3: Billing
            group "Billing Domain" {
                billingDB = container "Billing Database" "Stores transactions." "MySQL" "Type:Database"
                billingService = container "Billing Service" "Manages payments." "Java" {
                    group "Payment Modules" {
                        paymentModule = component "Payment Gateway" "Integrates with Stripe." "Spring" "Type:Module"
                        invoiceModule = component "Invoice Generator" "Creates statements." "Spring" "Type:Module"
                    }
                }
            }

            # Client Connections to API Layer
            webApp -> gateway "JSON/HTTPS"
            mobileApp -> gateway "JSON/HTTPS"
            thirdParty -> gateway "JSON/HTTPS"

            # API Layer Connections to all 3 Services
            gateway -> authModule "Routes Auth requests"
            gateway -> searchModule "Routes Catalog requests"
            gateway -> paymentModule "Routes Billing requests"

            # Data Isolation (The 'Per-Service DB' rule)
            authModule -> userDB "Reads/Writes"
            profileModule -> userDB "Reads/Writes"
            
            searchModule -> catalogDB "Queries"
            metadataModule -> catalogDB "Updates"
            
            paymentModule -> billingDB "Persists"
            invoiceModule -> billingDB "Reads"
        }
    }

    views {
        container system "MicroservicesView" {
            include *
            autoLayout tb
            description "Container view showing Gateway, Services, and private DBs."
        }
        
        component userService "UserServiceComponentView" {
            include *
            autoLayout
        }
        
        component catalogService "CatalogServiceComponentView" {
            include *
            autoLayout
        }
        
        component billingService "BillingServiceComponentView" {
            include *
            autoLayout
        }

        styles {
            element "Type:Gateway" {
                background #08427b
                color #ffffff
            }
            element "Type:Module" {
                background #1168bd
                color #ffffff
            }
            element "Type:Database" {
                shape Cylinder
                background #666666
                color #ffffff
            }

            # Group styling using 'element' with 'Group:' prefix
            # Attributes are strictly split per line
            element "Group:Identity Domain" {
                color #08427b
                border solid
            }
            element "Group:Catalog Domain" {
                color #1168bd
                border solid
            }
            element "Group:Billing Domain" {
                color #4b0082
                border solid
            }
        }
    }
}
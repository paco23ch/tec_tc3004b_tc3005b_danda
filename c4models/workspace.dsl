workspace "Banking System" "Layered Architecture using Groups." {

    model {
        customer = person "Banking Customer"
        
        softwareSystem = softwareSystem "Banking API" {
            database = container "Database" "Stores transactions." "Relational DB" "Database"
            
            api = container "API Application" "Provides banking logic." "Spring Boot" {
                
                group "Presentation Layer" {
                    signinController = component "Sign-in Controller" "Handles login requests." "Spring MVC" "Layer:Presentation"
                    accountsController = component "Accounts Controller" "Provides account summaries." "Spring MVC" "Layer:Presentation"
                }
                
                group "Application Layer" {
                    authService = component "Security Service" "Handles encryption." "Spring Service" "Layer:Application"
                    accountService = component "Account Service" "Orchestrates business rules." "Spring Service" "Layer:Application"
                }
                
                group "Domain Layer" {
                    accountRepository = component "Account Repository" "Persistence logic." "Spring Data" "Layer:Domain"
                }

                # Relationships that respect the boundary
                customer -> signinController "Uses"
                customer -> accountsController "Uses"
                
                signinController -> authService "Calls"
                accountsController -> accountService "Calls"
                
                accountService -> accountRepository "Accesses"
                accountRepository -> database "SQL/TCP"
            }
        }
    }

    views {
        component api "ComponentView" {
            include *
            autoLayout lr
            description "The component diagram showing explicit layer boundaries."
        }

        styles {
            element "Layer:Presentation" { 
                background #08427b 
                color #ffffff 
            }
            element "Layer:Application" { 
                background #1168bd 
                color #ffffff 
            }
            element "Layer:Domain" { 
                background #438dd5 
                color #ffffff
            }
            element "Database" { 
                shape Cylinder
            }
            
            # Styling the group boundaries themselves
            element "Group:Presentation Layer" { 
                color #08427b 
                border dashed
            }
            element "Group:Application Layer" { 
                color #1168bd 
                border dashed
            }
            element "Group:Domain Layer" { 
                color #438dd5 
                border dashed
            }
        }
    }
}
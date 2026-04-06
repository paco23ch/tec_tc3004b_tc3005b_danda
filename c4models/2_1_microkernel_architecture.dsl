workspace "Payment Gateway" "A microkernel-based payment processor." {

    model {
        customer = person "Online Shopper" "Initiates a payment."
        
        system = softwareSystem "Payment System" {
            api = container "Payment Engine" "The microkernel application." "Java/Spring" {
                
                group "Core System (Microkernel)" {
                    registry = component "Plugin Registry" "Tracks active payment providers." "Java" "Type:Core"
                    orchestrator = component "Payment Orchestrator" "Handles the core transaction workflow." "Java" "Type:Core"
                    adapter = component "Plugin Interface" "The contract plugins must implement." "Java Interface" "Type:Core"
                }
                
                group "Plug-in Modules" {
                    stripePlugin = component "Stripe Plugin" "Handles Stripe-specific API calls." "Java/Jar" "Type:Plugin"
                    paypalPlugin = component "PayPal Plugin" "Handles PayPal-specific API calls." "Java/Jar" "Type:Plugin"
                    cryptoPlugin = component "Crypto Plugin" "Handles Blockchain transactions." "Java/Jar" "Type:Plugin"
                }

                # Core Workflow
                customer -> orchestrator "Submits payment"
                orchestrator -> registry "Checks for available providers"
                
                # Plugin Interaction
                orchestrator -> adapter "Calls through"
                adapter -> stripePlugin "Delegates to"
                adapter -> paypalPlugin "Delegates to"
                adapter -> cryptoPlugin "Delegates to"
            }
        }
    }

    views {
        component api "MicrokernelView" {
            include *
            autoLayout tb
            description "Microkernel Architecture showing Core vs. Plug-ins."
        }

        styles {
            element "Type:Core" {
                background #08427b
                color #ffffff
            }
            element "Type:Plugin" {
                background #1168bd
                color #ffffff
            }
            
            # Applying your specific multi-line attribute requirement
            element "Group:Core System (Microkernel)" {
                color #08427b
                border solid
            }
            element "Group:Plug-in Modules" {
                color #1168bd
                border dashed
            }
        }
    }
}
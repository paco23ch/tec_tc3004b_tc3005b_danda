workspace "E-commerce Broker" "Decentralized choreography using an Event Broker." {

    model {
        user = person "Customer" "Places an order."
        
        system = softwareSystem "E-commerce Platform" {
            # The Broker (The 'Music' for the choreography)
            broker = container "Message Broker" "Decentralized event distribution." "RabbitMQ / Kafka" "Backbone"
            
            app = container "Microservices App" "Distributed services." "Spring Boot" {
                
                group "Order Domain" {
                    orderService = component "Order Service" "Creates orders and emits 'OrderPlaced' events." "Java" "Type:Producer"
                }
                
                group "Event Brokerage" {
                    orderTopic = component "Orders Topic" "A queue for order events." "Message Queue" "Type:Backbone"
                }
                
                group "Fulfillment Domain" {
                    # These services 'listen' and act independently
                    inventoryService = component "Inventory Service" "Listens for 'OrderPlaced' to reserve stock." "Java" "Type:Broker"
                    paymentService = component "Payment Service" "Listens for 'OrderPlaced' to authorize funds." "Java" "Type:Broker"
                    shippingService = component "Shipping Service" "Listens for 'PaymentAuthorized' to pack goods." "Java" "Type:Broker"
                }

                # Relationship Flow (The Choreography)
                user -> orderService "Checks out"
                
                # The Brokerage Interaction
                orderService -> orderTopic "Publishes 'OrderPlaced'"
                orderTopic -> broker "Ingests"
                
                # Distributed Reaction (No central coordinator)
                broker -> inventoryService "Broadcasts 'OrderPlaced'"
                broker -> paymentService "Broadcasts 'OrderPlaced'"
                
                # Chain Reaction
                paymentService -> shippingService "Emits 'PaymentAuthorized' directly or via Broker"
            }
        }
    }

    views {
        component app "BrokerView" {
            include *
            autoLayout lr
            description "Broker Pattern: Services react to events without a central orchestrator."
        }

        styles {
            element "Type:Producer" {
                background #08427b
                color #ffffff
            }
            element "Type:Backbone" {
                background #666666
                color #ffffff
            }
            element "Type:Broker" {
                background #1168bd
                color #ffffff
            }
            
            # Group styling using the 'Group:' prefix and element tag
            # Each attribute is strictly on its own line
            element "Group:Order Domain" {
                color #08427b
                border dashed
            }
            element "Group:Event Brokerage" {
                color #666666
                border solid
            }
            element "Group:Fulfillment Domain" {
                color #1168bd
                border dashed
            }
        }
    }
}
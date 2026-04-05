workspace "E-commerce EDA" "A decoupled event-driven fulfillment system." {

    model {
        user = person "Customer" "Places an order."
        
        fulfillmentSystem = softwareSystem "Fulfillment System" {
            bus = container "Event Bus" "Message broker for asynchronous events." "Apache Kafka" "Backbone"
            
            app = container "Fulfillment Application" "Logic for processing orders." "Node.js" {
                
                group "Event Producers" {
                    orderService = component "Order Service" "Accepts orders and emits 'OrderCreated' events." "TypeScript" "Type:Producer"
                }
                
                group "Streaming Backbone" {
                    eventBuffer = component "Event Buffer" "Temporary storage for high-volume streams." "Kafka Topic" "Type:Backbone"
                }
                
                group "Event Consumers" {
                    inventoryService = component "Inventory Service" "Decrements stock levels upon order." "TypeScript" "Type:Consumer"
                    paymentService = component "Payment Service" "Processes transactions." "TypeScript" "Type:Consumer"
                    emailService = component "Notification Service" "Sends confirmation emails." "TypeScript" "Type:Consumer"
                }

                # Relationship Flow
                user -> orderService "Submits Order"
                
                # The Pub/Sub interaction
                orderService -> eventBuffer "Publishes 'OrderCreated'"
                eventBuffer -> bus "Streams to"
                
                # Decoupled Consumption
                bus -> inventoryService "Notifies (Asynchronous)"
                bus -> paymentService "Notifies (Asynchronous)"
                bus -> emailService "Notifies (Asynchronous)"
            }
        }
    }

    views {
        component app "EDAView" {
            include *
            autoLayout lr
            description "Event-Driven Architecture: Decoupling Producers from Consumers."
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
            element "Type:Consumer" {
                background #1168bd
                color #ffffff
            }
            
            # Group styling using the 'element' tag with 'Group:' prefix
            # Each attribute is strictly on its own line
            element "Group:Event Producers" {
                color #08427b
                border dashed
            }
            element "Group:Streaming Backbone" {
                color #666666
                border solid
            }
            element "Group:Event Consumers" {
                color #1168bd
                border dashed
            }
        }
    }
}
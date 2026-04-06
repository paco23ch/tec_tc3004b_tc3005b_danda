workspace "Hexagonal System" "Decoupling Core Logic from Infrastructure." {

    model {
        user = person "Data Scientist" "Triggers model retraining/inference."
        
        system = softwareSystem "ML Platform" {
            
            group "Primary Adapters (Drivers)" {
                webUI = container "Inference Dashboard" "Web interface for users." "React" "Type:UI"
                apiGateway = container "API Gateway" "REST entry point." "FastAPI" "Type:UI"
            }

            group "Domain Hexagon (The Core)" {
                inferenceService = container "Inference Service" "The heart of the application." "Python/PyTorch" "Type:Core" {
                    # Internal Components
                    inputPort = component "Data Ingest Port" "Interface for incoming data."
                    domainModel = component "Scoring Engine" "The actual ML model logic."
                    outputPort = component "Persistence Port" "Interface for saving results."
                }
            }

            group "Secondary Adapters (Driven)" {
                featureStore = container "Feature Store" "Source of truth for model inputs." "PostgreSQL" "Type:Database"
                resultBucket = container "Results Sink" "Stores inference logs." "AWS S3" "Type:Storage"
            }

            # Relationships
            user -> webUI "Uses"
            webUI -> apiGateway "Calls"
            apiGateway -> inputPort "Sends features"
            
            # Internal Core flow
            inputPort -> domainModel "Passes validated data"
            domainModel -> outputPort "Requests persistence"
            
            # Secondary Adapter implementations
            inputPort -> featureStore "Fetches raw data"
            outputPort -> resultBucket "Writes JSON results"
        }
    }

    views {
        # L1: System Context
        systemContext system "SystemContext" {
            include *
            autoLayout lr
        }

        # L2: Container View (The drill-down destination from L1)
        container system "Containers" {
            include *
            autoLayout lr
        }

        # L3: Component View (The drill-down destination from L2)
        # This is what you were missing!
        component inferenceService "InferenceComponentView" {
            include *
            autoLayout lr
            description "Internal components of the Inference Service (The Hexagon)."
        }

        styles {
            element "Type:UI" {
                background #08427b
                color #ffffff
            }
            element "Type:Core" {
                background #1168bd
                color #ffffff
            }
            element "Type:Database" {
                shape Cylinder
                background #666666
                color #ffffff
            }
            element "Type:Storage" {
                shape Folder
                background #999999
                color #ffffff
            }

            # Group styling with strict single-line attributes
            element "Group:Primary Adapters (Drivers)" {
                color #08427b
                border dashed
            }
            element "Group:Domain Hexagon (The Core)" {
                color #1168bd
                border solid
            }
            element "Group:Secondary Adapters (Driven)" {
                color #666666
                border dashed
            }
        }
    }
}
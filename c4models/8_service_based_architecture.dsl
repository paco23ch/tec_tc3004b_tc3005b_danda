workspace "Electronics Recycling System" "Service-based architecture with shared persistence." {

    model {
        # Users
        customer = person "Wholesale Customer" "Submits bulk recycling lots."
        technician = person "Warehouse Technician" "Handles receiving and assessment."
        accountant = person "Accounting Clerk" "Manages billing and reporting."

        recyclingSystem = softwareSystem "Recycling Management Platform" {
            
            # Shared Data Tier
            centralDB = container "Recycling Database" "Single source of truth for all lots and items." "PostgreSQL Cluster" "Type:Database"

            # Coarse-Grained Services
            group "Customer Domain" {
                quoteService = container "Quoting Service" "Generates estimates for recycling lots." "Java" "Type:Service" {
                    pricingEngine = component "Pricing Engine" "Calculates market value of components."
                    quoteValidator = component "Quote Validator" "Checks against current inventory capacity."
                }
            }

            group "Operations Domain" {
                receivingService = container "Receiving Service" "Logs incoming pallets and generates tracking IDs." "Node.js" "Type:Service" {
                    barcodeModule = component "Barcode Generator" "Creates unique asset tags."
                }
                assessmentService = container "Assessment Service" "Technical evaluation of hardware condition." "Node.js" "Type:Service" {
                    specsModule = component "Specs Extractor" "Automatically pulls hardware specs."
                    gradingModule = component "Grading Logic" "Assigns A/B/C condition grades."
                }
                statusService = container "Item Status Service" "Real-time tracking of item location." "Go" "Type:Service"
            }

            group "Processing Domain" {
                recyclingService = container "Recycling & Salvage Service" "Manages teardown and component recovery." "Java" "Type:Service" {
                    salvageModule = component "Salvage Tracker" "Records recovered raw materials (Gold, Copper)."
                }
            }

            group "Back Office Domain" {
                accountingService = container "Accounting & Reporting Service" "Final settlement and compliance reports." "C#" "Type:Service" {
                    invoiceModule = component "Invoice Generator" "Creates customer payouts."
                    complianceModule = component "R2/RIOS Reporting" "Generates environmental audit logs."
                }
            }

            # UIs
            customerPortal = container "Customer Portal" "Web interface for lot submission." "React" "Type:UI"
            warehouseApp = container "Warehouse Mobile App" "Scanner-integrated app for techs." "React Native" "Type:UI"
            adminConsole = container "Admin Dashboard" "Internal management and reporting." "Angular" "Type:UI"

            # Relationships
            customer -> customerPortal "Submits lots"
            technician -> warehouseApp "Scans items"
            accountant -> adminConsole "Generates reports"

            customerPortal -> quoteService "Requests quote"
            warehouseApp -> receivingService "Checks in pallet"
            warehouseApp -> assessmentService "Updates grade"
            warehouseApp -> statusService "Queries location"
            adminConsole -> accountingService "Triggers settlement"

            # Shared Database Connections (The 'Service-Based' Marker)
            quoteService -> centralDB "Reads/Writes"
            receivingService -> centralDB "Reads/Writes"
            assessmentService -> centralDB "Reads/Writes"
            statusService -> centralDB "Reads"
            recyclingService -> centralDB "Reads/Writes"
            accountingService -> centralDB "Reads/Writes"
        }
        
        prodEnv = deploymentEnvironment "Production Environment" {
            
            deploymentNode "Database Subnet" {
                deploymentNode "RDS Aurora" "High Availability Cluster" {
                    dbInst = containerInstance centralDB
                }
            }

            deploymentNode "Application Tier" "Amazon EKS" {
                deploymentNode "Operations Pod" "Scales based on warehouse activity." {
                    recvInst = containerInstance receivingService
                    assessInst = containerInstance assessmentService
                    statusInst = containerInstance statusService
                }
                deploymentNode "Financial Pod" "Heavy lifting for reporting." {
                    quoteInst = containerInstance quoteService
                    accInst = containerInstance accountingService
                }
            }

            deploymentNode "Edge" "CloudFront / S3" {
                uiInst1 = containerInstance customerPortal
                uiInst2 = containerInstance adminConsole
            }
        }
    }

    views {
        systemContext recyclingSystem {
            include *
            autolayout tb
        }
        
        container recyclingSystem "ServiceBasedView" {
            include *
            autoLayout tb
        }
            
        component quoteService "QuoteComponentView" {
            include *
            autoLayout
        }
    
        component assessmentService "AssessmentComponentView" {
            include *
            autoLayout
        }
    
        component accountingService "AccountingComponentView" {
            include *
            autoLayout
        }
        
        component recyclingService "RecyclinngComponentView" {
            include *
            autoLayout
        }
        
        component receivingService "ReceivingComponentView" {
            include *
            autoLayout
        }
        
        deployment recyclingSystem "Production Environment" "Recycling_Deployment_View" {
            include *
            autoLayout tb
        }

        styles {
            element "Type:UI" {
                background #08427b
                color #ffffff
            }
            element "Type:Service" {
                background #1168bd
                color #ffffff
            }
            element "Type:Database" {
                shape Cylinder
                background #666666
                color #ffffff
            }

            # Group Styling (Strict Formatting)
            element "Group:Customer Domain" {
                color #08427b
                border solid
            }
            element "Group:Operations Domain" {
                color #1168bd
                border dashed
            }
            element "Group:Processing Domain" {
                color #228b22
                border solid
            }
            element "Group:Back Office Domain" {
                color #4b0082
                border dashed
            }
        }
    }
}
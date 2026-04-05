workspace "Enterprise Banking SOA" "A multi-tier SOA landscape for a retail bank." {

    model {
        # Users and Clients
        customer = person "Bank Customer" "Uses banking services."
        clerk = person "Bank Clerk" "Processes internal applications."
        
        # Systems
        bankingSystem = softwareSystem "Banking Platform" "Core enterprise services." {
            
            # 1. Business Services (Coarse-grained, business-process focused)
            group "Business Services" {
                loanService = container "Loan Approval Service" "Orchestrates the end-to-end loan process." "Java/Soap" "Type:Business" {
                    creditCheck = component "Credit Scoring Module" "Rules engine for risk."
                    underwriting = component "Underwriting Module" "Financial validation logic."
                }
                accountService = container "Account Opening Service" "Handles new customer onboarding." "Java/Soap" "Type:Business"
            }

            # 2. Message Bus (The ESB / Integration Layer)
            group "Message Bus" {
                choreographer = container "Process Choreographer" "Manages long-running BPEL business processes." "IBM MQ / BPM" "Type:Bus"
                orchestrator = container "Service Orchestrator" "Coordinates atomic service calls into composite services." "WSDL/SOAP" "Type:Bus"
            }

            # 3. Enterprise Services (Reusable, domain-specific)
            group "Enterprise Services" {
                customerService = container "Customer Info Service" "Single view of the customer across all branches." "C#" "Type:Enterprise"
                ledgerService = container "General Ledger Service" "Core financial accounting and transaction logging." "Java" "Type:Enterprise"
                enterpriseDB = container "Enterprise Data Warehouse" "Centralized repository for analytics and reporting." "Oracle DB" "Type:Database"
            }

            # 4. Application Services (Fine-grained, application-specific)
            group "Application Services" {
                gateway = container "Enterprise API Gateway" "Central entry point for all external traffic." "Kong / Apigee" "Type:Gateway"
                mobileBackend = container "Mobile App API" "Specific logic for the iOS/Android experience." "Node.js" "Type:App"
                atmService = container "ATM Integration Service" "Handles physical machine interactions." "C++" "Type:App"
            }

            # 5. Infrastructure Services (Technical utilities)
            group "Infrastructure Services" {
                notifyService = container "Notification Service" "Handles SMS, Email, and Push." "Python" "Type:Infra"
                auditService = container "Audit & Logging Service" "Centralized compliance logging." "Java" "Type:Infra"
            }

            # Interactions (All two-way as requested)
            customer -> gateway "Uses"
            clerk -> gateway "Uses"
            gateway -> mobileBackend "Routes to"
            gateway -> loanService "Routes to"

            # Business Services <-> Process Choreographer
            loanService -> choreographer "Initiates process"
            choreographer -> loanService "Updates state"
            
            # Service Orchestrator <-> Enterprise Services
            orchestrator -> customerService "Fetches data"
            customerService -> orchestrator "Returns profile"
            orchestrator -> ledgerService "Posts transaction"
            ledgerService -> orchestrator "Confirm status"

            # Enterprise Services <-> Application Services
            mobileBackend -> customerService "Requests profile"
            customerService -> mobileBackend "Provides profile"

            # Enterprise Services <-> Infrastructure Services
            ledgerService -> auditService "Logs financial event"
            auditService -> ledgerService "Ack"
            customerService -> notifyService "Sends alert"
            notifyService -> customerService "Ack"

            # Application Services <-> Infrastructure Services
            mobileBackend -> notifyService "Sends push"
            notifyService -> mobileBackend "Ack"
            
            # Data interactions
            customerService -> enterpriseDB "Query/Persist"
            ledgerService -> enterpriseDB "Sync daily totals"
        }
        
        # Second System for Enterprise Audit
        auditSystem = softwareSystem "External Audit System" "Government regulatory reporting."
        auditService -> auditSystem "Forwards compliance logs"
        
        # Infrastructure Nodes
        prod = deploymentEnvironment "Production" {
            onPrem = deploymentNode "On-Premise Data Center" "Primary Bank DC (Zone A)" "VMware vSphere" {
                
                deploymentNode "Mainframe / Oracle Cluster" "High-availability database tier." "Oracle Exadata" {
                    enterpriseDbInstance = containerInstance enterpriseDB
                }
    
                deploymentNode "Application Server Cluster" "Java EE Runtime for core services." "WebSphere" {
                    loanServiceInstance = containerInstance loanService
                    ledgerServiceInstance = containerInstance ledgerService
                    choreographerInstance = containerInstance choreographer
                }
            }
    
            publicCloud = deploymentNode "Public Cloud" "AWS / Azure" "Region: us-east-1" {
                
                deploymentNode "Kubernetes Cluster" "EKS / AKS" "Production Environment" {
                    
                    deploymentNode "Consumer Namespace" "Edge services for end-users." "K8s Namespace" {
                        mobileBackendInstance = containerInstance mobileBackend
                        gatewayInstance = containerInstance gateway
                    }
    
                    deploymentNode "Utility Namespace" "Shared infrastructure services." "K8s Namespace" {
                        notifyServiceInstance = containerInstance notifyService
                        auditServiceInstance = containerInstance auditService
                    }
                }
            }            
        }

    }

    views {
        container bankingSystem "SOA_Full_View" {
            include *
            autoLayout lr
        }
        
        deployment bankingSystem "Production" "Hybrid_Deployment_View" {
            include *
            autoLayout tb
            description "The hybrid deployment topology for the Banking SOA."
        }

        styles {
            # Base Elements
            element "Type:Business" {
                background #08427b
                color #ffffff
            }
            element "Type:Bus" {
                background #ff9900
                color #000000
            }
            element "Type:Enterprise" {
                background #1168bd
                color #ffffff
            }
            element "Type:Database" {
                shape Cylinder
                background #666666
                color #ffffff
            }

            # Group Styling (Strict Formatting)
            element "Group:Business Services" {
                color #08427b
                border solid
            }
            element "Group:Message Bus" {
                color #ff9900
                border dashed
            }
            element "Group:Enterprise Services" {
                color #1168bd
                border solid
            }
            element "Group:Application Services" {
                color #4b0082
                border dashed
            }
            element "Group:Infrastructure Services" {
                color #333333
                border solid
            }
            
            # Standard attribute formatting: one per line
            element "Deployment Node" {
                background #ffffff
                color #000000
                border solid
            }
            
            # Use 'Group:' prefix for visual clusters if needed
            element "Group:On-Premise Data Center" {
                color #08427b
                border solid
            }
            
            element "Group:Public Cloud" {
                color #1168bd
                border dashed
            }
        }
    }
}
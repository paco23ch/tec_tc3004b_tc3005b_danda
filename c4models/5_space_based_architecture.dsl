workspace "SBA System" "Extreme Scalability via In-Memory Data Grids." {

    model {
        user = person "User" "Sends high-frequency requests."
        
        system = softwareSystem "Space-Based Application" {
            
            appSpace = container "Application Space" "The virtualized environment." {
                
                group "Virtualized Middleware" {
                    msgGrid = component "Messaging Grid" "Manages request flow and session stickiness." "Middleware" "Type:Middleware"
                    dataGrid = component "Data Grid" "Coordinates data partitioning and consistency." "Middleware" "Type:Middleware"
                    procGrid = component "Processing Grid" "Orchestrates parallel task execution across units." "Middleware" "Type:Middleware"
                    depManager = component "Deployment Manager" "Manages dynamic startup/shutdown of units." "Middleware" "Type:Middleware"
                }
                
                group "Processing Unit 1" {
                    modules1 = component "Business Modules (PU 1)" "Application logic." "Logic" "Type:PU"
                    imdg1 = component "Local IMDG (PU 1)" "In-memory data store for this unit." "Memory" "Type:PU"
                    replEngine1 = component "Replication Engine (PU 1)" "Syncs local data with the Space." "Engine" "Type:PU"
                }

                group "Processing Unit 2 (Scaled)" {
                    modules2 = component "Business Modules (PU 2)" "Cloned application logic." "Logic" "Type:PU"
                    imdg2 = component "Local IMDG (PU 2)" "In-memory data store for this unit." "Memory" "Type:PU"
                    replEngine2 = component "Replication Engine (PU 2)" "Syncs local data with the Space." "Engine" "Type:PU"
                }

                # External Interactions
                user -> msgGrid "Sends Request"

                # Middleware to PU Interactions
                msgGrid -> modules1 "Routes Request"
                msgGrid -> modules2 "Routes Request (Load Balanced)"
                procGrid -> modules1 "Orchestrates Parallel Task"
                depManager -> modules1 "Lifecycle Management (Spin up/down)"
                
                # Internal PU Interactions
                modules1 -> imdg1 "Read/Write (Microseconds)"
                imdg1 -> replEngine1 "Triggers Sync"
                
                # Data Grid Coordination
                replEngine1 -> dataGrid "Pushes Data Update"
                dataGrid -> replEngine2 "Broadcasts Update to Peers"
            }
        }
    }

    views {
        component appSpace "SBAView" {
            include *
            autoLayout lr
            description "Space-Based Architecture: Middleware Grids vs. Processing Units."
        }

        styles {
            element "Type:Middleware" {
                background #08427b
                color #ffffff
            }
            element "Type:PU" {
                background #1168bd
                color #ffffff
            }
            
            # Group styling using 'element' with 'Group:' prefix
            # Each attribute on a single line per requirements
            element "Group:Virtualized Middleware" {
                color #08427b
                border solid
            }
            element "Group:Processing Unit 1" {
                color #1168bd
                border dashed
            }
            element "Group:Processing Unit 2 (Scaled)" {
                color #1168bd
                border dashed
            }
        }
    }
}
workspace "Teaching Architecture" "Example for 2008 MacBook Cluster" {

    !identifiers hierarchical
    !adrs doc/adr

    model {
        # 1. People (Actors)
        student = person "Student" "Learns software architecture." "User"
        professor = person "Professor" "Teaches the class using Structurizr" "User"

        # 2. Software Systems
        teachingSystem = softwareSystem "Teaching Platform" "Allows students to view C4 models." {
            
            # 3. Containers (Applications/Data)
            webapp = container "Web Application" "React/Chromium interface." "JavaScript"
            api = container "API Gateway" "Handles requests for architecture data." "Python/FastAPI"
            db = container "Database" "Stores architecture metadata." "PostgreSQL" "Database"
            
            # Internal Relationships
            webapp -> api "Makes API calls to" "JSON/HTTPS"
            api -> db "Reads from and writes to" "SQL"
        }

        # External Systems
        github = softwareSystem "GitHub" "Stores the DSL source code." "External"

        # Global Relationships
        professor -> teachingSystem.webapp "Edits models via"
        student -> teachingSystem.webapp "Views diagrams on"
        teachingSystem.api -> github "Pulls latest DSL from"
    }

    views {
        # Level 1: System Context
        systemContext teachingSystem "Context" {
            include *
            autolayout lr
        }

        # Level 2: Container Diagram
        container teachingSystem "Containers" {
            include *
            autolayout tb
        }

        # Level 3: Component Diagram (Optional - requires more DSL detail)
        
        styles {
            element "User" { 
                            background "#08427b" 
                            color "#ffffff" 
                            shape person 
                            }
            element "Software System" { 
                            background #1168bd 
                            color #ffffff 
                            }
            element "Container" { 
                            background #438dd5 
                            color #ffffff 
                            }
            element "Database" { 
                            shape cylinder 
                            }
        }
    }
}

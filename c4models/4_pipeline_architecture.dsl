workspace "Log Analytics" "A standard Pipe and Filter architecture for log ingestion." {

    model {
        admin = person "System Admin" "Views processed logs."
        
        system = softwareSystem "Logging Platform" {
            storage = container "Elasticsearch" "Stores processed logs." "Search Engine" "Type:Sink"
            
            pipeline = container "Log Processor" "The pipeline application." "Go / Fluentd" {
                
                group "Ingestion Stage" {
                    reader = component "Log Reader" "Reads raw files from disk." "File Tailer" "Type:Pipe"
                }
                
                group "Transformation Stages" {
                    sanitizer = component "PII Sanitizer" "Removes sensitive data like passwords." "Filter" "Type:Filter"
                    enricher = component "GeoIP Enricher" "Adds location data based on IP address." "Filter" "Type:Filter"
                    formatter = component "JSON Formatter" "Converts raw text to structured JSON." "Filter" "Type:Filter"
                }
                
                group "Output Stage" {
                    writer = component "Bulk Writer" "Batches logs for efficient storage." "Pipe" "Type:Pipe"
                }

                # The sequential data flow
                reader -> sanitizer "Raw log string"
                sanitizer -> enricher "Sanitized log"
                enricher -> formatter "Enriched log"
                formatter -> writer "Structured JSON"
                writer -> storage "Index request"
                admin -> storage "Queries logs"
            }
        }
    }

    views {
        component pipeline "PipelineView" {
            include *
            autoLayout lr
            description "Pipeline Architecture: A linear flow of data through filters."
        }

        styles {
            element "Type:Pipe" {
                background #08427b
                color #ffffff
            }
            element "Type:Filter" {
                background #1168bd
                color #ffffff
            }
            element "Type:Sink" {
                background #666666
                color #ffffff
                shape Cylinder
            }
            
            # Group styling using the 'element' tag with 'Group:' prefix
            # Each attribute is strictly on its own line
            element "Group:Ingestion Stage" {
                color #08427b
                border dashed
            }
            element "Group:Transformation Stages" {
                color #1168bd
                border solid
            }
            element "Group:Output Stage" {
                color #08427b
                border dashed
            }
        }
    }
}
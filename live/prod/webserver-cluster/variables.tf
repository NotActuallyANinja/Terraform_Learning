#Defining the port as a variable means I am not repeating myself by having 8080 manually typed in when it needs to be r>#Also reduces effort typing in 8080 each time I deploy the EC2 instance

variable "server_port" {
        description     = "The port the server will use for http requests"
        type            = number
        default         = 8080
}
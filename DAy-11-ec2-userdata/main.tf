resource "aws_instance" "name" {
    ami           = "ami-0152204c1a187337c"
    instance_type = "t3.micro"
    user_data = <<-EOF
                #!/bin/bash
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                echo "Hello, World! from NIT" > /var/www/html/index.html
                EOF

                #user data is a script that will be executed on the instance when it is launched. In this case, we are installing and starting the Apache web server and creating a simple index.html file.
                #modification is possible  to the user data script to customize? no, the instance as per your requirements. For example, you can install additional software, configure services, or run any other commands that you want to execute on the instance at launch time.
                #once server laucnhed we cannot modify the user data script directly. However, we can use provisioners to run commands on the instance after it has been created. 
                #We can modift existig user data script by using provisoners without delete and recreate the instance. We can use provisioners to run commands on the instance after it has been created, allowing us to modify the user data script or perform any other necessary configuration changes without needing to delete and recreate the instance.
           
    tags = {    
        Name = "MyInstance"
    }
  
}
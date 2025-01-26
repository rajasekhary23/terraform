 #!/bin/bash
    set -e

    echo "Updating system packages..."
    sudo apt-get update -y
    sudo apt-get upgrade -y

    echo "Installing required dependencies..."
    sudo apt-get install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

    # Install OpenJDK 17 (headless)
    echo "Installing OpenJDK 17..."
    sudo apt-get install -y openjdk-17-jre-headless

    # Verify JDK installation
    java -version

    # Install Maven
    echo "Installing Maven..."
    sudo apt-get install -y maven

    # Verify Maven installation
    mvn -version

    # Install Docker
    echo "Installing Docker..."
    sudo apt-get install -y docker.io

    # Enable and start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker

    # Add current user to the Docker group
    sudo usermod -aG docker ubuntu

    # Verify Docker installation
    docker --version

    # Install Jenkins
    echo "Adding Jenkins repository and key..."
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

    echo "Installing Jenkins..."
    sudo apt-get update -y
    sudo apt-get install -y jenkins

    # Enable and start Jenkins service
    sudo systemctl enable jenkins
    sudo systemctl start jenkins

    echo "Installation complete!"
    echo "To access Jenkins, visit: http://<your-server-ip>:8080"
    echo "You can find the initial admin password here: /var/lib/jenkins/secrets/initialAdminPassword"
import subprocess
import time
import logging

logging.basicConfig(
    filename='ssh_connection_and_db.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Database connection configurations for different environments
staging_db = {
    'host': "127.0.0.1",
    'port': 5001,
    'user': "skoolboy",
    'password': "skoolpass123456",
    'database': "skoolnet2_uat"
}

devx_db = {
    'dev1': {
        'host': "127.0.0.1",
        'port': 5000,
        'user': "skoolboy",
        'password': "skoolpass123456",
        'database': "skoolnet2_dev1"
    },
    'dev3': {
        'host': "127.0.1.1",
        'port': 5000,
        'user': "skoolboy",
        'password': "skoolpass123456",
        'database': "skoolnet2_dev2"
    },
    'devy': {
        'host': "127.0.0.2",
        'port': 5000,
        'user': "skoolboy",
        'password': "skoolpass123456",
        'database': "skoolnet2_devy"
    }
}

# Function to establish SSH connection based on the selected environment
def establish_ssh_connection(environment="devx"):
    """Establish an SSH connection based on the specified environment."""
    try:
        logging.info(f"Attempting to establish SSH connection for {environment}.")
        
        if environment == "staging":
            process = subprocess.Popen(
                ['gcloud', 'compute', '--project', 'tcc-sn-dev', 'ssh', 'bastion-01', '--zone', 'asia-southeast1-a', '--', '-p', '22', '-L', '5001:34.124.233.222:3306'],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            stdout, stderr = process.communicate()
            if stdout:
                logging.info(f"SSH connection established for Staging. Output: {stdout.decode()}")
            if stderr:
                logging.error(f"SSH connection errors for Staging: {stderr.decode()}")

        elif environment == "devx":
            process = subprocess.Popen(
                ['gcloud', 'compute', '--project', 'tcc-sn-dev', 'ssh', 'bastion-01', '--zone', 'asia-southeast1-a', '--', '-p', '22', '-L', '5000:35.240.154.123:3306'],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            stdout, stderr = process.communicate()
            if stdout:
                logging.info(f"SSH connection established for Devx. Output: {stdout.decode()}")
            if stderr:
                logging.error(f"SSH connection errors for Devx: {stderr.decode()}")
        else:
            raise ValueError("Unknown environment specified. Please use 'staging' or 'devx'.")
        
        time.sleep(5)  # Allow some time for the connection to establish
    except Exception as e:
        logging.error(f"Error establishing SSH connection: {e}")
        exit(1)

# Function to get the correct database configuration
def get_db_config(environment="devx", db="dev1"):
    """Get the database configuration based on the selected environment and database."""
    if environment == "staging":
        return staging_db
    elif environment == "devx":
        if db in devx_db:
            return devx_db[db]
        else:
            raise ValueError(f"Unknown database: {db}. Available databases for devx are: 'dev1', 'dev2', 'dev3'.")
    else:
        raise ValueError("Unknown environment specified. Please use 'staging' or 'devx'.")

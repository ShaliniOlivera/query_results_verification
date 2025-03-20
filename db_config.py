import pymysql

dev1 = {
    'host': "127.0.0.1",
    'port': 5005,
    'user': "skoolboy",
    'password': "skoolpass123456",
    'database': "skoolnet2_uat"
}

ms_dev02 = {
    'host': "127.0.0.1",
    'port': 5031,
    'user': "skoolboy_dev",
    'password': "Hasd@2020",
    'database': "sn2_class_ops_lsh_premium"
}

def get_connection(env="ms_dev02"):
    """Returns a database connection based on the specified environment."""
    config = ms_dev02 if env == "ms_dev02" else dev1
    return pymysql.connect(
        host=config['host'],
        port=config['port'],
        user=config['user'],
        password=config['password'],
        database=config['database'],
        autocommit=True
    )
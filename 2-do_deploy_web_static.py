#!/usr/bin/python3
# Fabfile to distribute an archive to web servers.

import os
from fabric.api import env, put, run

# Set up the Fabric environment
env.user = "ubuntu"
env.hosts = ['xx-web-01', 'xx-web-02']  # Replace with your server IPs

def do_deploy(archive_path):
    """Distributes an archive to web servers."""
    print(f"Starting deployment for: {archive_path}")

    # Check if the archive file exists
    if not os.path.isfile(archive_path):
        print(f"Error: Archive {archive_path} does not exist.")
        return False

    # Extract file name and remove extension for directory creation
    file_name = os.path.basename(archive_path)
    base_dir = file_name.split('.')[0]

    # Steps to deploy the archive to the web servers
    try:
        print(f"Uploading {file_name} to /tmp/...")
        put(archive_path, f"/tmp/{file_name}")

        print("Preparing deployment directory...")
        run(f"rm -rf /data/web_static/releases/{base_dir}/")
        run(f"mkdir -p /data/web_static/releases/{base_dir}/")

        print("Unpacking the archive...")
        run(f"tar -xzf /tmp/{file_name} -C /data/web_static/releases/{base_dir}/")

        print("Cleaning up the archive...")
        run(f"rm /tmp/{file_name}")

        print("Moving unpacked files to the correct location...")
        run(f"mv /data/web_static/releases/{base_dir}/web_static/* /data/web_static/releases/{base_dir}/")
        run(f"rm -rf /data/web_static/releases/{base_dir}/web_static")

        print("Updating the current symbolic link...")
        run("rm -rf /data/web_static/current")
        run(f"ln -s /data/web_static/releases/{base_dir}/ /data/web_static/current")

        print("Deployment successful!")
        return True
    except Exception as e:
        print(f"Deployment failed: {e}")
        return False


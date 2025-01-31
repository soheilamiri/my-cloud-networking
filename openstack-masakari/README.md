# OpenStack-Masakari

Welcome to the OpenStack-Masakari project! This repository provides modules to monitor OpenStack using SolarWinds, allowing you to keep track of Masakari services, reserved hosts, and members. The purpose of this project is to help people easily monitor their OpenStack environments via SolarWinds.

## Introduction
OpenStack-Masakari is designed to demonstrate how you can monitor your OpenStack environment using powershell and SolarWinds. The project includes three modules that focus on different aspects of Masakari monitoring:
1. Masakari Services Monitoring
2. Reserved Hosts Monitoring
3. Member Monitoring

Each module is designed to provide detailed insights and status updates for the specified components of your OpenStack environment.

## Modules
### 1. Masakari Services Monitoring
This module monitors the status of various Masakari and related services running in your OpenStack environment.

### 2. Reserved Hosts Monitoring
This module tracks the reserved hosts in your OpenStack environment, ensuring that they are functioning correctly.

### 3. Member Monitoring
This module monitors the status of members within your OpenStack environment, providing information about their availability and health.

## Prerequisites
Before you begin, ensure you have met the following requirements:
- OpenStack environment with Masakari services
- SolarWinds installed and configured
- PowerShell installed on your monitoring server
- SSH access to your OpenStack nodes

## Installation
To install and set up the monitoring modules, follow these steps:

1. Clone this repository to your local machine:
    ```sh
    git clone https://github.com/soheilamiri/my-cloud-networking/tree/main/openstack-masakari/openstack-masakari.git
    ```

2. Navigate to the project directory:
    ```sh
    cd openstack-masakari
    ```

3. Follow the instructions provided in each module's README file to set up and configure the monitoring scripts.

## Usage
To use the monitoring modules, execute the PowerShell scripts provided in each module. The scripts will connect to your OpenStack environment, gather the necessary information, and provide status updates via SolarWinds.

Example command to run a script:
```sh
.\Monitor-MasakariServices.ps1

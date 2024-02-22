# Ubuntu Server Security Hardening Script

## Overview
This repository contains a script designed to automate the security hardening process for Ubuntu servers. The script is intended to be run initially on a fresh server installation before any additional software or configurations are applied. It  implements a series of best practices and configurations to enhance the security posture of your Ubuntu server.

## Features
- Automatic installation and configuration of essential security tools.
- Harden system configurations to minimize vulnerabilities.
- Apply recommended firewall rules to restrict network access.
- Enhance user authentication and access controls.
- Enable system auditing for better visibility into security events.

## Requirements
- Ubuntu Server (tested on Ubuntu 18.04 and 20.04).
- Root or sudo access to the server.
- Internet connectivity to download necessary packages and updates.

## Usage
1. Clone this repository to your Ubuntu server:

    ```
    git clone https://github.com/your_username/ubuntu-server-security-hardening.git
    ```

2. Navigate to the cloned directory:

    ```
    cd ubuntu-server-security-hardening
    ```

3. Make the script executable:

    ```
    chmod +x harden.sh
    ```

4. Run the script with root privileges:

    ```
    sudo ./harden.sh
    ```

5. Follow the on-screen prompts to confirm actions and provide necessary inputs.

6. Sit back and let the script automate the security hardening process for your Ubuntu server.

## Disclaimer
- **Use at your own risk:** While the script aims to improve the security of your server, there is no guarantee that it will cover all possible vulnerabilities or suit every environment. Always review the changes made by the script and ensure they align with your security requirements.
- **Backup:** It's highly recommended to backup your server before running this script to mitigate any potential risks.

## Contributing
- Contributions, suggestions, and bug reports are welcome! If you encounter any issues or have ideas for improvements, feel free to open an issue or submit a pull request.

## License
This project is licensed under the [MIT License](LICENSE).

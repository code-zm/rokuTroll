# rokuTroll

An interactive Bash script to find Roku TV devices on a local network and Rick Roll them.  

---

## Disclaimer
**This script is provided for educational and entertainment purposes only. Please be aware of the following:**
- Only use this script on networks and devices that you own, have permission to use, or have explicit authorization to access.
- Scanning networks and controlling devices without consent is a violation of privacy and may be illegal.
- The creators and contributors of this script are not responsible for any misuse, damage, or legal issues that arise from using this script.

**By using this script, you agree to take full responsibility for your actions and comply with all applicable laws and regulations.**

---

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

---

### Features
- Network Scanning: Automatically scans your local network for Roku devices.
- Manual IP Option: Directly enter a device's IP address if you know it.
- Rick Roll: Sends commands to turn on the device, launch YouTube, and play "Never Gonna Give You Up" by Rick Astley.
- Interactive Menu: Provides options to proceed with the prank or exit gracefully.

---

### Prerequisites
Ensure you have the following installed and set up:
- Git: [Download and install Git](https://git-scm.com/downloads)
- nmap: A network scanning tool. Install it using:
    - On Ubuntu/Debian:
        ```bash
        sudo apt-get install nmap
        ```
    - On macOS:
        ```bash
        brew install nmap
        ```
- Bash: Your system should support Bash scripting (most Unix-based systems have this pre-installed).

---

### Installation
1. Clone the repository:
    ```bash
    git clone https://github.com/code-zm/rokuTroll.git
    ```

2. Navigate to the project directory:
    ```bash
    cd rokuTroll
    ```

3. Make the script executable:
    ```bash
    chmod +x rokuTroll.sh
    ```

---

### Usage
1. Run the script:
    ```bash
    ./rokuTroll.sh
    ```
2. Select an option:
   - Choose `[1]` to manually enter an IP address.
   - Choose `[2]` to scan the local network for Roku devices.

3. Follow the prompts:
   - If devices are found, select one from the list to proceed with the Rick Roll.
   - Confirm before initiating the prank.

---

### Contributing
Contributions are welcome! Please fork the repository and use a feature branch. Pull requests are welcome.

1. Fork the project
2. Create a feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

---

### License
This project is open-source and available under the MIT License. See the `LICENSE` file for more details.

---

### Acknowledgments
- Thanks to the creators of the [Roku External Control API](https://developer.roku.com/docs/developer-program/dev-tools/external-control-api.md).
- Thanks to [GitHub](https://github.com/) for hosting this project.

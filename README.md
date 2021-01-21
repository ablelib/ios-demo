
# AbleLib iOS Demo

iOS demo app for AbleLib - the premium mobile BLE library. Check it out at [https://ablelib.com](https://ablelib.com/).
This app demonstrates some of the Able SDK capabilities, and can be used as a starting point for integrating the library into your project.

## The App
The demo app app is split in four sections. Each of the section covers different parts of AbleLib functionality. 
### Scanning
![](/screenshots/start_scanning.png?raw=true)

![](/screenshots/scan_results.png?raw=true)


### Storage
Storage tab shows all previously paired devices with our phone. 

![](/screenshots/storage.png)

### Communication
Communication tab, like storage tab, shows all previously paired devices. It also lets you to connect to those devices and discover their services and characteristics.

![](/screenshots/connect.png?raw=true)

Click on "Connect" button next to device will try and connect to that device.  UI will then show some of the actions we can do. 
* Clicking on "Discover Services" we will attempt to retrieve all of peripheral services. 
* You can then also easily get the list of characteristics for each of those services. Click on one of these items from the list will update the list with characteristics of that service.

### Sockets

This tab allows you to test **socket communication**. It has two parts:

1. **server demo** - allows initialization of a local GATT server (i.e, peripheral mode) and an L2CAP server socket. The server hosts a service and a characteristic via which the PSM of the L2CAP channel can be obtained by client sockets.
1. **client demo** - allows for scanning for a peripheral that supports L2CAP server socket, and connecting to it in client mode.

After a socket connection is obtained, you can send text in either direction, effectively forming an instant chat service over BLE.

### Quality of Service
Quality of service tab will show you list of all "Scan configs" which AbleLib can use. 

from openwrt_luci_rpc import OpenWrtRpc

router = OpenWrtRpc('100.93.0.2', 'root', 'Ny3MJaOTg1Czuv')
devices = router.get_all_connected_devices()

with open('openwrt.hosts', 'w') as f:
    for device in devices:
        f.write(f"{device.ip} {device.hostname}\n")

for device in result:
   mac = device.mac
   name = device.hostname

   # convert class to a dict
   device_dict = device._asdict()
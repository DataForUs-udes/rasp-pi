import pygatt
import dbus
import dbus.mainloop.glib
import dbus.service
from gi.repository import GLib
import time

# Constants
ADAPTER_INTERFACE = 'org.bluez.Adapter1'
ADVERTISING_MANAGER_INTERFACE = 'org.bluez.LEAdvertisingManager1'
DEVICE_INTERFACE = 'org.bluez.Device1'
UUID = '12345678-1234-5678-1234-56789abcdef0'
SERVICE_UUID = '12345678-1234-5678-1234-56789abcdef1'
CHARACTERISTIC_UUID = '12345678-1234-5678-1234-56789abcdef2'

def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

    bus = dbus.SystemBus()
    adapter_path = '/org/bluez/hci0'
    adapter = dbus.Interface(bus.get_object('org.bluez', adapter_path), ADAPTER_INTERFACE)
    adapter_props = dbus.Interface(bus.get_object('org.bluez', adapter_path), 'org.freedesktop.DBus.Properties')

    # Set the adapter to be discoverable
    adapter_props.Set(ADAPTER_INTERFACE, 'Discoverable', dbus.Boolean(1))
    adapter_props.Set(ADAPTER_INTERFACE, 'Alias', 'Data For Us')

    # Register advertisement
    ad_manager = dbus.Interface(bus.get_object('org.bluez', adapter_path), ADVERTISING_MANAGER_INTERFACE)
    ad = Advertisement(bus, 0, UUID)
    ad_manager.RegisterAdvertisement(ad.get_path(), {}, reply_handler=register_ad_cb, error_handler=register_ad_error_cb)

    print('Advertisement registered')

    bus.add_signal_receiver(device_connected,
                            dbus_interface="org.freedesktop.DBus.Properties",
                            signal_name="PropertiesChanged",
                            path_keyword="path")

    mainloop = GLib.MainLoop()
    mainloop.run()

def device_connected(interface, changed, invalidated, path):
    if interface == DEVICE_INTERFACE:
        if 'Connected' in changed:
            if changed['Connected']:
                print(f'Device connected: {path}')
                send_file()
            else:
                print(f'Device disconnected: {path}')

def send_file():
    adapter = pygatt.GATTToolBackend()
    adapter.start()
    
    try:
        # Replace MAC address with the address of your connected device
        device = adapter.connect('78:4C:4B:A7:83:C2')
        with open('bomba.txt', 'r') as file:
            data = file.read()
        
        device.char_write(CHARACTERISTIC_UUID, bytearray(data, 'utf-8'))
        print('File sent successfully')
    except Exception as e:
        print(f'Failed to send file: {e}')
    finally:
        adapter.stop()

class Advertisement(dbus.service.Object):
    PATH_BASE = '/com/example/advertisement'

    def __init__(self, bus, index, uuid):
        self.path = self.PATH_BASE + str(index)
        self.bus = bus
        self.index = index
        self.uuid = uuid
        self.ad_type = 'peripheral'
        self.local_name = 'Data For Us'
        self.service_uuids = [uuid]
        self.manufacturer_data = dbus.Dictionary({}, signature='qv')
        self.solicit_uuids = dbus.Array([], signature='s')
        self.service_data = dbus.Dictionary({}, signature='sv')
        self.include_tx_power = dbus.Boolean(False)

        dbus.service.Object.__init__(self, bus, self.path)

    def get_properties(self):
        return {
            'org.bluez.LEAdvertisement1': {
                'Type': self.ad_type,
                'LocalName': self.local_name,
                'ServiceUUIDs': dbus.Array(self.service_uuids, signature='s'),
                'ManufacturerData': self.manufacturer_data,
                'SolicitUUIDs': self.solicit_uuids,
                'ServiceData': self.service_data,
                'IncludeTxPower': self.include_tx_power,
            }
        }

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_service_uuid(self, uuid):
        self.service_uuids.append(uuid)

    def add_manufacturer_data(self, manuf_code, data):
        self.manufacturer_data[manuf_code] = dbus.Array(data, signature='y')

    def add_service_data(self, uuid, data):
        self.service_data[uuid] = dbus.Array(data, signature='y')

    @dbus.service.method('org.freedesktop.DBus.Properties', in_signature='s', out_signature='a{sv}')
    def GetAll(self, interface):
        if interface != 'org.bluez.LEAdvertisement1':
            raise dbus.exceptions.DBusException('Invalid interface: ' + interface)

        return self.get_properties()[interface]

    @dbus.service.method('org.freedesktop.DBus.ObjectManager', out_signature='a{oa{sa{sv}}}')
    def GetManagedObjects(self):
        response = {}
        response[self.get_path()] = self.get_properties()
        return response

    @dbus.service.method('org.bluez.LEAdvertisement1', in_signature='', out_signature='')
    def Release(self):
        pass

def register_ad_cb():
    print('Advertisement registered successfully')

def register_ad_error_cb(error):
    print('Failed to register advertisement: ' + str(error))

if __name__ == '__main__':
    main()

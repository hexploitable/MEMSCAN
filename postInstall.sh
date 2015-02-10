scp -P $THEOS_DEVICE_PORT root@$THEOS_DEVICE_IP:/usr/bin/memscan .
ldid -Sentitlements.xml memscan
scp -P $THEOS_DEVICE_PORT memscan root@$THEOS_DEVICE_IP:/usr/bin/memscan

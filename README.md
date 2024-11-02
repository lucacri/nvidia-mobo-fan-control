# GPU Fan Control Service

This service controls the GPU fan speed based on temperature, implementing a custom fan curve with quick ramp-up and slow ramp-down behavior.

## Hardware Requirements & Context

This software was specifically developed for:
- NVIDIA GPUs only (requires nvidia-smi)
- Tested on MSI PRO Z690-A DDR4 motherboard
- Originally designed for a modified NVIDIA P40 card
- GPU fans must be powered by the motherboard
- Tested on Ubuntu 22.04

The software was created to address a specific need: controlling GPU fans that are powered by the motherboard rather than the GPU itself. In this setup, fan speed can be controlled by writing values (0-254) directly to the system fan control device (`/sys/devices/platform/nct6687.2592/hwmon/hwmon5/pwm2`).

This solution is particularly useful for server-grade GPUs (like the NVIDIA P40) that have been modified for desktop use, where the fans are connected to motherboard headers instead of being powered by the GPU directly.

## Installation Steps

1. Create the installation directory:
```bash
sudo mkdir -p /opt/gpu-fan-control
```

2. Copy the files to the installation directory:
```bash
sudo cp gpu-fan-control.sh /opt/gpu-fan-control/
sudo cp gpu-fan-control.service /etc/systemd/system/
```

3. Make the script executable:
```bash
sudo chmod +x /opt/gpu-fan-control/gpu-fan-control.sh
```

4. Reload systemd to recognize the new service:
```bash
sudo systemctl daemon-reload
```

5. Enable the service to start on boot:
```bash
sudo systemctl enable gpu-fan-control
```

6. Start the service:
```bash
sudo systemctl start gpu-fan-control
```

## Verifying Operation

Check if the service is running:
```bash
sudo systemctl status gpu-fan-control
```

View the service logs:
```bash
journalctl -u gpu-fan-control -f
```

## Fan Curve Details

- Below 40°C: Fan speed set to minimum (20)
- Between 40°C and 75°C: Linear interpolation from 20 to 254
- Above 75°C: Fan speed set to maximum (254)
- Fan speed increases immediately when temperature rises
- Fan speed decreases slowly when temperature drops

## Troubleshooting

If the service fails to start, check:
1. The script path is correct (/opt/gpu-fan-control/gpu-fan-control.sh)
2. The script has execute permissions
3. The fan control device exists (/sys/devices/platform/nct6687.2592/hwmon/hwmon5/pwm2)
4. nvidia-smi is installed and working

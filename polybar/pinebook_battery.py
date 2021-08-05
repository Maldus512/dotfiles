#!/usr/bin/env python
BATTERY = "/sys/class/power_supply/cw2015-battery"
CAPACITY = f"{BATTERY}/capacity"
STATUS = f"{BATTERY}/status"


if __name__ == "__main__":
    with open(CAPACITY, "r") as f:
        capacity = f.read().strip("\n") + "%"

    with open(STATUS, "r") as f:
        status = f.read().strip("\n")
        if status == "Charging":
            status = "*"
        else:
            status = "v"

    print(f"BAT {status}{capacity}")
    

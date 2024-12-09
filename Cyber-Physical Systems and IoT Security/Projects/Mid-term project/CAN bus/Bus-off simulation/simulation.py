import random
from can_bus import CANBus
from victim_ecu import VictimECU
from attacker_ecu import AttackerECU

def simulate_bus_off_attack():
    bus = CANBus()

    victim = VictimECU("Victim", bus)
    attacker = AttackerECU("Attacker", bus)

    # Configure victim's periodic messages
    victim.configure_periodic_frame(frame_id=0x100, data=[0xAA, 0xBB], interval_ms=500)
    victim.configure_periodic_frame(frame_id=0x200, data=[0xCC, 0xDD], interval_ms=1000)

    # Phase 1: Pattern analysis
    traffic = []
    for t in range(10000):
        victim.normal_behavior(t)
        result = bus.receive_frame()
        if result:
            frame, _ = result  # Extract the frame from the tuple
            traffic.append(frame)  # Append the frame data only

    attacker.analyze_pattern(traffic)

    # Phase 2: Attack execution
    if attacker.target_pattern:
        attacker.execute_attack(victim)

        print("[Simulation] Victim has entered bus-off state.")
    else:
        print("[Simulation] No valid target pattern identified; attack aborted.")

simulate_bus_off_attack()
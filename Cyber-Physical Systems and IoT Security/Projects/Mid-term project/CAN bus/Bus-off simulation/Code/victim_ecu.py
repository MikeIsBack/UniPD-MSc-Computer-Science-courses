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
                self.send({"id": frame_id, "data": data, "dlc": len(data)})

    def send_non_periodic_frame(self):
        """Send non-periodic messages with random IDs."""
        random_id = random.randint(*self.non_periodic_id_range)
        random_data = [random.randint(0, 255) for _ in range(random.randint(1, 8))]
        self.send({"id": random_id, "data": random_data, "dlc": len(random_data)})


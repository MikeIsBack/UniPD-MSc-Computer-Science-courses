import random
from ecu import ECU

class VictimECU(ECU):
    def __init__(self, name, bus):
        super().__init__(name, bus)
        self.preceded_frame = {
            "id": f"{0x080:011b}",
            "data": ["00000000"],
            "dlc": "0001"
        }
        self.periodic_frame = {
            "id": f"{0x100:011b}",
            "data": ["00000000"],
            "dlc": "0001"
        }
        self.non_periodic_id_range = (0x300, 0x3FF)

    def send_preceded_frame(self):
        """Send the preceded frame."""
        self.send(self.preceded_frame)  # Send the preceded frame

    def send_periodic_frame(self):
        """Send the periodic message."""
        self.send(self.periodic_frame)  # Send the periodic frame

    def send_non_periodic_frame(self):
        """Send non-periodic messages with random IDs."""
        random_id = random.randint(*self.non_periodic_id_range)
        random_data = [random.randint(0, 255) for _ in range(random.randint(1, 8))]
        frame = {
            "id": f"{random_id:011b}",
            "data": [f"{byte:08b}" for byte in random_data],
            "dlc": f"{len(random_data):04b}"
        }
        self.send(frame)  # Send the non-periodic frame

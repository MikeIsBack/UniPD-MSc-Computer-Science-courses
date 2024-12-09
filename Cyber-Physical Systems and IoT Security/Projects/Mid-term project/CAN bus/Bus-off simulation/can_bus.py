from collections import deque

class CANBus:
    def __init__(self):
        self.frames = deque()  # Queue to store CAN frames
        self.current_transmissions = []  # Tracks ECUs transmitting frames

    def send_frame(self, frame, ecu):
        """Send a frame onto the CAN bus."""
        if self.current_transmissions:  # Check if the bus is currently transmitting
            print(f"[CANBus] Frame dropped: {frame['id']} (Bus busy)")
            return

        print(f"[CANBus] ECU {ecu.name} sent frame with ID: {frame['id']}")
        self.current_transmissions.append((frame, ecu))

    def resolve_collisions(self):
        """Resolve collisions based on CAN arbitration rules."""
        if len(self.current_transmissions) > 1:
            print(f"[CANBus] Resolving collisions among {len(self.current_transmissions)} transmissions.")
            dominant_frame = self.current_transmissions[0][0]
            for frame, ecu in self.current_transmissions[1:]:
                if frame["id"] == dominant_frame["id"]:
                    print(f"[CANBus] Collision detected on frame ID: {frame['id']}")
                    for _, colliding_ecu in self.current_transmissions:
                        colliding_ecu.increment_error_counter(is_transmit_error=True)
                    self.current_transmissions = []  # Clear bus after collision
                    return None

        if self.current_transmissions:
            successful_frame = self.current_transmissions[0]
            print(f"[CANBus] Frame successfully transmitted: {successful_frame[0]['id']}")
            self.current_transmissions = []  # Clear bus after transmission
            return successful_frame

        return None

    def receive_frame(self):
        """Receive a frame from the CAN bus."""
        return self.resolve_collisions()
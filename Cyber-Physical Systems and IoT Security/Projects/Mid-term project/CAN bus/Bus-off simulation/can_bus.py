class CANBus:
    def __init__(self):
        self.current_transmissions = []  # Tracks ongoing transmissions on the bus

    def send_frame(self, frame, ecu):
        """Place a frame on the CAN bus."""
        self.current_transmissions.append((frame, ecu))  # Add frame to the queue

    def resolve_collisions(self):
        """Handle arbitration and collisions."""
        if len(self.current_transmissions) > 1:
            print(f"[CANBus] Collision detected among {len(self.current_transmissions)} nodes.")
            # Handle collision logic (simplified here)
            for _, ecu in self.current_transmissions:
                ecu.increment_error_counter(is_transmit_error=True)
            self.current_transmissions = []  # Clear bus due to collision
        elif self.current_transmissions:
            frame, sender = self.current_transmissions.pop(0)  # Process first frame in the queue
            print(f"[CANBus] Frame successfully transmitted: {frame['id']} by {sender.name}")
            sender.decrement_error_counters()  # Reset TEC after success
            return frame

    def receive_frame(self):
        """Retrieve and process the next frame."""
        if not self.current_transmissions:  # Check if there are frames to process
            return None  # If no frames are available, return None
        return self.resolve_collisions()  # Resolve any collisions

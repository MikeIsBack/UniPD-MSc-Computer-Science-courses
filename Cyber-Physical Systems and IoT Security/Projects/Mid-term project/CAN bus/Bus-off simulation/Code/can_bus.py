from collections import deque

class CANBus:
    def __init__(self):
        self.frames = deque()  # Queue to store CAN frames

    def send_frame(self, frame):
        """Send a frame onto the CAN bus."""
        self.frames.append(frame)

    def receive_frame(self):
        """Receive a frame from the CAN bus."""
        if self.frames:
            return self.frames.popleft()
        return None

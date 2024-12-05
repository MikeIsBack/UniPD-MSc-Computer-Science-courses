class ECU:
    def __init__(self, name, bus):
        self.name = name
        self.bus = bus
        self.transmit_error_counter = 0
        self.receive_error_counter = 0
        self.is_error_passive = False
        self.is_bus_off = False

    def send(self, frame):
        """Transmit a CAN frame."""
        if self.is_bus_off:
            print(f"[{self.name}] Cannot send; ECU is in Bus-off state!")
            return

        print(f"[{self.name}] Sending frame: {frame}")
        self.bus.send_frame(frame)

    def listen(self):
        """Listen for a frame on the CAN bus."""
        if self.is_bus_off:
            return

        frame = self.bus.receive_frame()
        if frame:
            print(f"[{self.name}] Received frame: {frame}")

    def increment_error_counter(self, is_transmit_error):
        """Increment the error counter."""
        if is_transmit_error:
            self.transmit_error_counter += 8
        else:
            self.receive_error_counter += 1

        if not self.is_error_passive and (self.transmit_error_counter > 127 or self.receive_error_counter > 127):
            self.is_error_passive = True
            print(f"[{self.name}] Entered Error-Passive state.")
        if self.transmit_error_counter > 255:
            self.is_bus_off = True
            print(f"[{self.name}] Entered Bus-Off state!")

    def decrement_error_counters(self):
        """Reduce error counters after successful operations."""
        self.transmit_error_counter = max(0, self.transmit_error_counter - 1)
        self.receive_error_counter = max(0, self.receive_error_counter - 1)

        if self.is_error_passive and (self.transmit_error_counter <= 127 and self.receive_error_counter <= 127):
            self.is_error_passive = False
            print(f"[{self.name}] Entered Error-Active state.")

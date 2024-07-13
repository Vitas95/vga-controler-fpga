"""
Script controls text edditing via FPGA VGA screen controller.
FPGA module has internal text video memory module that length depends on the
screen resolution. Text memory is designed for 128 character ascii set.
Communication with the FPGA is performed by the serial port. To change one character
on the screen threebytes should be transmitted to the FPGA:
         
        |---address byte 2---|---address byte 1---|---char byte---|

Address bytes specify position of the transmitted character in the text memory.
Symplification of the FPGA screen controller means that all other text additing features 
lie on the shoulders of this script. For example, address of the current position 
of the cursor (mem_pointer) is stored inon of the variables.
"""

from serial import Serial
from pynput import keyboard

# Screen parameters
# FPGA uses a 8x8 bit font. With 800x600 resolution
# 100 symbols fits in one line and 75 in one column.
screen_width = 100
screen_height = 75
text_mem_length = screen_width * screen_height - 1
mem_pointer = 0

# Serial port parameters to communicate with the FPGA
ser = Serial("COM4")
ser.baudrate = 9600


def send_character(mem_pointer, character):
    if mem_pointer <= 255:
        address_1 = 0
        address_2 = mem_pointer
    else:
        address_1 = mem_pointer - 255
        address_2 = 255
    ser.write((chr(address_2) + chr(address_1) + character).encode("utf-8"))


def on_press(key):
    global mem_pointer
    if 1:
        try:
            send_character(mem_pointer, key.char)
            mem_pointer += 1
            send_character(mem_pointer, chr(1))

        except AttributeError:
            if key == key.enter:
                mem_pointer += 100
                send_character(mem_pointer, chr(1))
            elif key == key.space:
                send_character(mem_pointer, chr(32))
                mem_pointer += 1
                send_character(mem_pointer, chr(1))
            elif key == key.backspace:
                send_character(mem_pointer, chr(32))
                if mem_pointer > 0:
                    mem_pointer -= 1
                    send_character(mem_pointer, chr(1))
            elif key == key.up:
                if mem_pointer > 100:
                    send_character(mem_pointer, chr(32))
                    mem_pointer -= 100
                    send_character(mem_pointer, chr(1))
            elif key == key.down:
                if mem_pointer < text_mem_length - 100:
                    send_character(mem_pointer, chr(32))
                    mem_pointer += 100
                    send_character(mem_pointer, chr(1))
            elif key == key.left:
                send_character(mem_pointer, chr(32))
                mem_pointer -= 1
                send_character(mem_pointer, chr(1))
            elif key == key.right:
                send_character(mem_pointer, chr(32))
                mem_pointer += 1
                send_character(mem_pointer, chr(1))


# Escape when escape key
def on_release(key):
    if key == keyboard.Key.esc:
        # Stop listener
        return False


if __name__ == "__main__":

    # Collect events until released
    with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
        listener.join()

    # Set cursor
    send_character(mem_pointer, chr(1))

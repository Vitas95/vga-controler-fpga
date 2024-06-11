import cv2
import numpy as np
import argparse


def img_to_mem(img_path, path_write, dac_resolution):
    # Load the image
    img = cv2.imread(img_path)
    height, width, channels = img.shape

    b = img[:, :, 0]
    g = img[:, :, 1]
    r = img[:, :, 2]

    if dac_resolution != [8, 8, 8]:
        # Change image depth
        EightBitsToNBits_V = np.vectorize(EightBitsToNBits)
        b = EightBitsToNBits_V(b, dac_resolution[0])
        g = EightBitsToNBits_V(g, dac_resolution[1])
        r = EightBitsToNBits_V(r, dac_resolution[2])

        # Display the image to check the result
        edit_img = np.zeros((height, width, 3), np.uint8)
        NBitstoEightBits_V = np.vectorize(NBitstoEightBits)
        edit_img[:, :, 0] = NBitstoEightBits_V(b, dac_resolution[0])
        edit_img[:, :, 1] = NBitstoEightBits_V(g, dac_resolution[1])
        edit_img[:, :, 2] = NBitstoEightBits_V(r, dac_resolution[2])
        cv2.imshow("Image", edit_img)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    # Convert the image
    b = b.reshape(-1, 1)
    g = g.reshape(-1, 1)
    r = r.reshape(-1, 1)

    # Save data
    text_data = ""
    for i in range(b.shape[0]):
        text_data = (
            text_data
            + bin(r[i][0])[2:].zfill(dac_resolution[2])
            + bin(g[i][0])[2:].zfill(dac_resolution[1])
            + bin(b[i][0])[2:].zfill(dac_resolution[0])
            + "\n"
        )

    # Save file
    file_name_write = "MemoryFile.txt"
    if path_write != "":
        file_name_write = path_write + "/" + file_name_write

    with open(file_name_write, "w+") as f:
        f.write(text_data[:-1])
        f.close()


def EightBitsToNBits(channel, N):
    return round((channel * ((2**N) - 1)) / 255.0)


def NBitstoEightBits(channel, N):
    return channel * 255.0 / ((2**N) - 1)


if __name__ == "__main__":

    # Parse command line arguments
    parser = argparse.ArgumentParser(
        description="Takes the image and converts its depth to the required one."
    )
    parser.add_argument(
        "-f", "--file", type=str, help="Path to the input image", required=True
    )
    parser.add_argument(
        "-p",
        "--path",
        type=str,
        help="Path to save the file",
        default="",
    )
    parser.add_argument(
        "-r",
        "--depthred",
        type=int,
        help="Depth of the red color",
        default=8,
    )
    parser.add_argument(
        "-g",
        "--depthgreen",
        type=int,
        help="Depth of the green color",
        default=8,
    )
    parser.add_argument(
        "-b",
        "--depthblue",
        type=int,
        help="Depth of the blue color",
        default=8,
    )
    args = parser.parse_args()

    # path_read = "C:/Users/user/Documents/FPGA/Altera projects/vga-controler-fpga/images_for_conversion"
    # file_name = "swan_bird_reflection_1199499_240x320.jpg"
    # path_write = "C:/Users/user/Documents/FPGA/Altera projects/vga-controler-fpga/image_mem"

    img_to_mem(args.file, args.path, [args.depthred, args.depthgreen, args.depthblue])

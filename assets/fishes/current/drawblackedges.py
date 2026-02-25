import os
import glob
from PIL import Image, ImageFilter, ImageChops

def process_outlines():
    # Find all files ending specifically with _alpha.png
    files = glob.glob("*_alpha.png")
    
    if not files:
        print("No _alpha.png files found in this directory.")
        return

    for file_path in files:
        print(f"Processing: {file_path}...")
        
        # Open image and ensure RGBA
        base = Image.open(file_path).convert("RGBA")
        r, g, b, a = base.split()

        # Create the outline mask using MaxFilter (Dilation)
        # MaxFilter(3) expands the alpha by roughly 1 pixel in all directions
        expanded_alpha = a.filter(ImageFilter.MaxFilter(3))
        
        # Subtract the original alpha to keep ONLY the new border pixels
        edge_mask = ImageChops.subtract(expanded_alpha, a)

        # Create a solid black image the same size as the base
        black_layer = Image.new("RGBA", base.size, (0, 0, 0, 255))
        
        # Composite the black layer onto the base using the edge_mask as the guide
        # This replaces the need for a manual 'for' loop through pixels
        outlined_image = Image.composite(black_layer, base, edge_mask)

        # Generate the new filename: smallswim_alpha.png -> smallswim_outlined.png
        output_name = file_path.replace("_alpha.png", "_outlined.png")
        outlined_image.save(output_name)
        print(f"Saved: {output_name}")

if __name__ == "__main__":
    process_outlines()
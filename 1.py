import os

# Folder path where your images are stored
image_folder = r'D:\GitHub\kinetic_qr\screenshots'

# Path to the README file
readme_file = 'README.md'

# Image size definition for markdown (optional CSS styles can be used to control size)
image_size = 'width="200"'

# Supported image extensions
image_extensions = ['.png', '.jpg', '.jpeg', '.gif']

# Get all image files from the folder
image_files = [f for f in os.listdir(image_folder) if os.path.splitext(f)[1].lower() in image_extensions]

# Open the README file in append mode
with open(readme_file, 'a') as readme:
    readme.write("\n## Screenshots\n")  # Add a title for the images section
    for image in image_files:
        image_path = os.path.join(image_folder, image)
        # Add markdown for each image with custom size
        readme.write(f'\n<img src="{image_path}" {image_size}>\n')

print(f'Images have been added to {readme_file}')

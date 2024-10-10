import os

# Your GitHub repository URL
repo_url = 'https://github.com/jnvshubham7/kinetic_qr/raw/main/screenshot/'

# Path to the Screenshot folder
screenshot_folder = 'screenshot'
readme_path = 'README.md'

# Check if the folder exists
if not os.path.exists(screenshot_folder):
    print(f"Folder '{screenshot_folder}' does not exist.")
else:
    # List all files in the Screenshot folder
    files = os.listdir(screenshot_folder)
    
    # Filter out only image files (assuming png format) and sort them numerically
    image_files = sorted([f for f in files if f.endswith('.png')], key=lambda x: int(os.path.splitext(x)[0].split('_')[1]))

    if not image_files:
        print("No image files found in the Screenshot folder.")
    else:
        # Generate markdown for images
        markdown_content = "<p float=\"left\">\n"
        for image in image_files:
            image_url = repo_url + '/' + image
            markdown_content += f'  <img src="{image_url}" width="200" />\n'
        markdown_content += "</p>\n"

        # Read the current content of README.md
        with open(readme_path, 'r') as readme_file:
            readme_content = readme_file.readlines()

        # Find the index to insert the screenshots section
        start_index = -1
        for i, line in enumerate(readme_content):
            if line.strip() == "## Screenshots":
                start_index = i
                break

        # Insert the new markdown content for screenshots
        if start_index != -1:
            readme_content = readme_content[:start_index+1] + [markdown_content]

            # Write the updated content back to README.md
            with open(readme_path, 'w') as readme_file:
                readme_file.writelines(readme_content)

            print("README.md updated with new screenshots section.")
        else:
            print("Could not find '## Screenshots' section in README.md.")

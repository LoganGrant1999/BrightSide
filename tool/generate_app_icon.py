#!/usr/bin/env python3
"""
Generate BrightSide App Icon
Creates a 1024x1024 sun icon with rays

Requirements: pip install pillow
"""

from PIL import Image, ImageDraw
import math

def create_app_icon():
    """Create main app icon with white background"""
    size = 1024
    img = Image.new('RGB', (size, size), '#FFFFFF')
    draw = ImageDraw.Draw(img)

    center_x = size // 2
    center_y = size // 2

    # Sun circle
    sun_radius = 180
    sun_color = '#FFB800'  # Primary brand color

    # Draw sun circle
    draw.ellipse(
        [center_x - sun_radius, center_y - sun_radius,
         center_x + sun_radius, center_y + sun_radius],
        fill=sun_color
    )

    # Draw rays
    num_rays = 12
    ray_length = 120
    ray_width = 40
    ray_start_distance = sun_radius + 30

    for i in range(num_rays):
        angle = (2 * math.pi * i) / num_rays

        # Start point (edge of sun)
        start_x = center_x + math.cos(angle) * ray_start_distance
        start_y = center_y + math.sin(angle) * ray_start_distance

        # End point (tip of ray)
        end_x = center_x + math.cos(angle) * (ray_start_distance + ray_length)
        end_y = center_y + math.sin(angle) * (ray_start_distance + ray_length)

        # Perpendicular offset for width
        perp_angle = angle + math.pi / 2
        offset_x = math.cos(perp_angle) * (ray_width / 2)
        offset_y = math.sin(perp_angle) * (ray_width / 2)

        # Draw ray as polygon (triangle)
        ray_points = [
            (start_x + offset_x, start_y + offset_y),
            (start_x - offset_x, start_y - offset_y),
            (end_x, end_y)
        ]
        draw.polygon(ray_points, fill=sun_color)

    return img

def create_foreground_icon():
    """Create adaptive icon foreground with transparent background"""
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    center_x = size // 2
    center_y = size // 2

    # Sun circle (slightly larger for adaptive icon)
    sun_radius = 200
    sun_color = '#FFB800'

    # Draw sun circle
    draw.ellipse(
        [center_x - sun_radius, center_y - sun_radius,
         center_x + sun_radius, center_y + sun_radius],
        fill=sun_color
    )

    # Draw rays
    num_rays = 12
    ray_length = 140
    ray_width = 45
    ray_start_distance = sun_radius + 30

    for i in range(num_rays):
        angle = (2 * math.pi * i) / num_rays

        start_x = center_x + math.cos(angle) * ray_start_distance
        start_y = center_y + math.sin(angle) * ray_start_distance

        end_x = center_x + math.cos(angle) * (ray_start_distance + ray_length)
        end_y = center_y + math.sin(angle) * (ray_start_distance + ray_length)

        perp_angle = angle + math.pi / 2
        offset_x = math.cos(perp_angle) * (ray_width / 2)
        offset_y = math.sin(perp_angle) * (ray_width / 2)

        ray_points = [
            (start_x + offset_x, start_y + offset_y),
            (start_x - offset_x, start_y - offset_y),
            (end_x, end_y)
        ]
        draw.polygon(ray_points, fill=sun_color)

    return img

if __name__ == '__main__':
    import os

    # Get the assets/icon directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)
    icon_dir = os.path.join(project_dir, 'assets', 'icon')

    # Create directory if it doesn't exist
    os.makedirs(icon_dir, exist_ok=True)

    # Generate icons
    print('Generating app_icon.png...')
    app_icon = create_app_icon()
    app_icon.save(os.path.join(icon_dir, 'app_icon.png'))
    print('✓ Generated app_icon.png (1024x1024)')

    print('\nGenerating app_icon_foreground.png...')
    foreground_icon = create_foreground_icon()
    foreground_icon.save(os.path.join(icon_dir, 'app_icon_foreground.png'))
    print('✓ Generated app_icon_foreground.png (1024x1024)')

    print('\n✅ Icon generation complete!')
    print('\nNext steps:')
    print('1. Run: flutter pub run flutter_launcher_icons:main')
    print('2. Check ios/Runner/Assets.xcassets/AppIcon.appiconset')
    print('3. Build and test on device/simulator')
